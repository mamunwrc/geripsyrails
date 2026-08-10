class Grp::Encounter < ApplicationRecord
  audited

  include Enc::EncounterCertificationHelpers

  CannotCertifyIndividualNotesError = Class.new(StandardError)

  self.referral_base :group_therapy_session
  self.referral_fields :service_date

  belongs_to :group, class_name: 'Grp::Group'
  belongs_to :signer, class_name: 'Usr::Provider', foreign_key: :signed_by, optional: true

  has_many :patient_notes, dependent: :destroy
  has_many :addendums, dependent: :destroy
  has_many :patients, -> { distinct }, through: :patient_notes

  serialize :group_therapy_session, HashSerializer
  serialize :interventions, HashSerializer
  serialize :certification, HashSerializer

  attr_accessor :certify

  scope :unsigned, -> { where(signed_on: nil) }
  scope :signed, -> { where.not(signed_on: nil) }
  scope :ordered_by_service_date, -> { order("group_therapy_session->>'service_date'") }

  before_validation :ensure_note_patients_exist, if: -> {unsigned?}

  before_save :capture_certification, if: -> { certify }
  before_save :ensure_dates_utc_midnight

  after_validation :copy_to_patients, if: -> {certify}

  validates :group_id, presence: true

  with_options if: -> { certify } do |encounter|
    encounter.validates :service_date, presence: true
    encounter.validate :has_enough_patients, :service_date_unique
  end

  store_accessor :group_therapy_session, :service_date

  def signed?
    signed_on && signed_by
  end

  def unsigned?
    !signed?
  end

  def session_patients
    Pat::Patient.where(id: session_patient_ids)
  end

  def session_encounters
    Enc::Encounter.where({
      cpt_encounter_code: '90853',
      patient_id: session_patient_ids
    }).where("(group_data ->> 'session_id')::int = ?", id)
  end

  def pdfname
    export_name 'pdf'
  end

  def docxname
    export_name 'zip'
  end

  private

  def export_name(ext)
    "Group-#{group.name.downcase}-#{service_date.to_date}.#{ext}"
  end

  def has_enough_patients
    return true if session_patients.count > 1

    errors.add(:session_patients, 'less than 2')
  end

  def service_date_unique
    return unless service_date

    sdate = service_date.to_date
    return true if group.encounters.signed.where.not(id: id).
      where("group_therapy_session ->> 'service_date' BETWEEN ? AND ?", sdate, sdate.tomorrow).
      blank?
  end

  def ensure_note_patients_exist
    return unless unsigned? and group
    patient_notes.each(&:save)
  end

  def __session_patients__
    group_therapy_session.patients ||= []
  end

  def session_patient_ids
    __session_patients__.map(&:name)
  end

  def copy_to_patients
    pids =  session_patient_ids & group.patient_ids
    patients = Pat::Patient.where(id: pids).includes(:encounters)
    session = group_therapy_session.deep_dup
    session.delete(:patients)
    session.participants = patients.count
    service_date = session.delete(:service_date)

    group_data = {
      group_id: group.id,
      session_id: id,
      interventions: interventions,
      session: session,
      name: group.name
    }

    uncertify = false
    Enc::Encounter.transaction do
      encounters = patients.map do |patient|
        note_query = patient_notes.joins(:patients).where('pat_patients.id = ?', patient.id)
        group_data[:individual_notes] = note_query.where(confidential: false).pluck(:body)
        group_data[:confidential_notes] = note_query.confidential.pluck(:body)
        latest = patient.encounters.signed.reorder("referral->>'service_date'").last
        enc_data = latest.data_fields
        enc_data.referral ||= {}
        enc_data.referral.service_date = service_date
        enc_data.group_data = group_data
        enc_data.certification = certification
        Enc::Encounter.new({
          provider_id: provider_id,
          patient_id: patient.id,
          cpt_encounter_code: '90853',
          certify: true,
          group_session: self,
        }.merge(enc_data.to_h))
      end
      encounters.each do |encounter|
        unless encounter.save
          uncertify = true
          raise ActiveRecord::Rollback
        end
      end
    end

    if uncertify
      self.certify = self.signed_by = self.signed_on = nil

      errors.add(:certifying, 'could not certify individual notes')
      raise CannotCertifyIndividualNotesError, "individual encounters could not be signed"
    else
      SendGroupNotesJob.perform_later(id)
    end
  end
end
