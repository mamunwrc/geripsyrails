class Enc::EncounterSimpleSerializer < ActiveModel::Serializer
  attributes :id, :cpt_encounter_code, :updated_at, :signed_on, :encounter_type, :service_date, :patient_id
  attribute(:certified) { !!object.signed_on }

  attribute(:diagnosis) { object.diagnosis.try(:primary).try(:val)}

  attribute(:unbilled) { !object.billable? }

  belongs_to :signer
  belongs_to :patient
  has_many :addendums

  class PatientSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :full_name, :dob, :facility_id, :room_num, :gender, :insurance
  end
end
