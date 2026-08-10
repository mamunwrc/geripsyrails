class Adm::FacilitySerializer < ActiveModel::Serializer
  attributes :id, :name, :address1, :address2, :city, :admin_first_name, :admin_last_name, :admin_email, :home_phone, :npi, :work_phone, :zip, :country, :hp_main_pos_code, :hp_alt_pos_code
  attribute(:state) { { val: object.state, name: object.state }}
  attribute(:medicare) { { val: object.medicare, name: object.medicare }}
  attribute :providers do
    object.providers.select(:id, :npi, :ptan).map do |prov|
      {
        name: prov.full_name,
        id: prov.id,
        npi: prov.npi,
        ptan: prov.ptan
      }
    end
  end

  has_many :doctors
  has_many :facility_contacts
end

