class Grp::GroupSerializer < ActiveModel::Serializer
  attributes :id, :name
  attribute :contact_email, if: -> { current_user.admin? }
  attribute :contact_active, if: -> { current_user.admin? }
  has_many :patients
  has_one :unsigned_encounter

  class PatientSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :dob
  end
end
