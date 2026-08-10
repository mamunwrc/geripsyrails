class Usr::ReviewerSerializer < ActiveModel::Serializer
  attributes :id, :associated_patients, :associated_facilities, :associated_providers
  attribute(:reviewer_type) { { val: object.reviewer_type, name: object.reviewer_type } }
  has_one :user
end
