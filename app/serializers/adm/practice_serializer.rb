class Adm::PracticeSerializer < ActiveModel::Serializer
  attributes :id, :name, :address1, :address2, :city, :zip, :admin_id, :tax_number

  attribute(:practice_type){ { name: object.practice_type, val: object.practice_type } }
  attribute(:state) { { val: object.state, name: object.state } }

  has_many :users
  has_many :facilities
end
