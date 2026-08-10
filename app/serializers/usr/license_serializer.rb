class Usr::LicenseSerializer < ActiveModel::Serializer
  attributes :id, :number, :expiration

  attribute(:state) { { val: object.state, name: object.state } }
end
