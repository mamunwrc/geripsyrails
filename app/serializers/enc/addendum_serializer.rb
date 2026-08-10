class Enc::AddendumSerializer < ActiveModel::Serializer
  attributes :id, :note, :created_at
  belongs_to :user
end
