class Pat::PatientSimpleSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :dob, :has90791, :ssn, :insurance_data, :full_name, :gender, :status, :room_num, :primary_provider_id, :facility_pos_code, :prior_authorization_number
  belongs_to :facility

  attribute :providers do
    object.providers.map{|pro| {id: pro.id, full_name: pro.full_name} }
  end

  class FacilitySerializer < ActiveModel::Serializer
    attributes :id, :name, :npi
  end
end
