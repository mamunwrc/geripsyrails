class Pat::InsuranceSerializer < ActiveModel::Serializer
  attributes :id, :name, :hp_id_code, :payerid, :address1, :address2, :city, :zip
  attribute(:medicare_hmo) { object.medicare_hmo? }
  attribute(:state) { { val: object.state, name: object.state } }
end

