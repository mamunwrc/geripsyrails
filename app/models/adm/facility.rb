class Adm::Facility < ApplicationRecord
  NoAltPOSCodeError = Class.new(StandardError)

  audited

  include HealthpacCode

  hp_code_base "FAC"

  belongs_to :practice

  has_many :patients, class_name: 'Pat::Patient'
  has_many :doctors, class_name: 'Adm::FacilityDoctor'
  has_many :providers, -> { distinct }, through: :patients, class_name: 'Usr::Provider'
  has_many :facility_contacts

  validates :name, presence: true
  validates :practice_id, presence: true
  validates :hp_alt_pos_code, numericality: true, allow_nil: true
  validates :hp_main_pos_code, numericality: true, allow_nil: true

  accepts_nested_attributes_for :doctors

  enum medicare: { downstate: 1, queens: 2, carolina: 47 }, _prefix: true

  def hp_code_for(encounter)
    if encounter.alt_pos?
      hp_code hp_alt_pos_code
    elsif hp_main_pos_code
      hp_code hp_main_pos_code
    else
      hp_code
    end
  end
end
