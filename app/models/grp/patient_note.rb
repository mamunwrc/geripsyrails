class Grp::PatientNote < ApplicationRecord
  audited

  belongs_to :encounter, class_name: 'Grp::Encounter'

  has_many :note_subjects, class_name: 'Grp::NoteSubject', dependent: :destroy
  has_many :patients, through: :note_subjects, class_name: 'Pat::Patient'

  validates :body, presence: true

  attr_accessor :incoming_patient_ids

  before_validation :update_patients, if: ->{ encounter.unsigned? }

  scope :confidential, -> { where(confidential: true) }

  private

  def update_patients
    ids = (encounter.group_therapy_session.patients || []).map(&:name)
    if Array(incoming_patient_ids).present?
      self.patients = Pat::Patient.where(id: ids & incoming_patient_ids)
    elsif (patient_ids & ids).present? && ids.sort != patient_ids.sort
      self.patients = Pat::Patient.where(id: ids & patient_ids)
    elsif (ids & patient_ids).blank?
      destroy!
    end
  end
end
