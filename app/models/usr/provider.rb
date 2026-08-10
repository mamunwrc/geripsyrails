class Usr::Provider < ApplicationRecord
  audited

  include HealthpacCode
  hp_code_base "PRO"

  INCIDENT_TO_PROVIDER_CODES = [
    '90834',
    '90832',
    '90837',
    '90846',
    '90847',
    '90875',
    '90853',
    'GBH1',
    'TP',
  ].freeze
  public_constant(:INCIDENT_TO_PROVIDER_CODES)

  has_many :licenses
  accepts_nested_attributes_for :licenses, allow_destroy: true

  has_one :user, as: :meta, dependent: :destroy
  accepts_nested_attributes_for :user

  belongs_to :practice, class_name: 'Adm::Practice'
  has_and_belongs_to_many :patients, class_name: "Pat::Patient", join_table: "patients_providers"
  has_many :facilities, through: :practice, class_name: 'Adm::Facility'
  has_many :encounters, through: :patients, class_name: 'Enc::Encounter'

  belongs_to :linked_provider, class_name: 'Usr::Provider', foreign_key: :linked_provider_id, optional: true
  has_many :incident_to_providers, class_name: 'Usr::Provider', foreign_key: :linked_provider_id

  has_many :incident_to_patients, class_name: 'Pat::Patient', foreign_key: :incident_to_provider_id

  has_many :leaders, class_name: 'Grp::Leader'
  has_many :groups, through: :leaders, class_name: 'Grp::Group'

  validates :licenses, presence: true
  validates :degree, presence: true
  validates :hp_account, uniqueness: true, allow_blank: true
  validates :practice_id, presence: true

  delegate :full_name, to: :user

  def self.order_by_ids(ids)
    return order(:id) if ids.blank?

    order_by = ["case"]
    ids.each.with_index do |id, idx|
      order_by << "WHEN id='#{id}' THEN #{idx}"
    end
    order_by << "end"

    order(order_by.join(" "))
  end

  def incident_to_provider?
    linked_provider_id != nil
  end

  def incident_to_patient_ids
    encounters.collect(&:patient_id).uniq
  end

  def encounters
    if incident_to_provider?
      linked_provider.encounters.where(cpt_encounter_code: INCIDENT_TO_PROVIDER_CODES, patient: patients)
    else
      super
    end
  end

  def patients
    if incident_to_provider?
      incident_to_patients
    else
      super
    end
  end

  def patient_ids=(ids)
    patients.where.not(id: ids).where(primary_provider_id: id).each(&:reprimarize!)
    super(ids)
  end

  def name_with_title
    [full_name, degree].join(", ")
  end
end

