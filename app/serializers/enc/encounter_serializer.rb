class Enc::EncounterSerializer < ActiveModel::Serializer
  attributes :id, :cpt_encounter_code, :updated_at, :signed_on, :encounter_type, :service_date, :patient_id, :code_modifier, :facility_pos_code,
    *Enc::Encounter::DATA_FIELDS
  attribute(:certified) { !!object.signed_on }
  attribute(:has_interactive_complexity) { object.has_interactive_complexity? }
  attribute(:has_90840) { object.has_90840? }
  attribute(:data_fields) { Enc::Encounter::DATA_FIELDS }
  attribute(:fu_header) { ['90832', '98966'].include?(object.cpt_encounter_code) && object.follow_up_header(true) }
  attribute(:testing_service_dates) { object.cpt_encounter_code == '96116' && object.testing_service_dates }

  # NOTE
  #
  # We will be adding an unbilled flag to encounters
  # Will still need this check for group_billable
  attribute(:unbilled) { !object.billable? }

  belongs_to :incident_to_provider, serializer: Usr::ProviderSerializer
  belongs_to :signer
  belongs_to :patient
  has_many :addendums

  class PatientSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :full_name, :dob, :insurance_data, :room_num, :facility_pos_code
  end
end
