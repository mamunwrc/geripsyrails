class Usr::AdminSerializer < ActiveModel::Serializer
  attributes :id

  attribute(:practice_id) { { name: object.practice_id, val: object.practice.name } }

  has_one :user
end
