class Usr::UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :address1, :city, :zip, :timezone, :home_phone, :work_phone, :meta
  attribute(:state) { { val: object.state, name: object.state }}
  attribute(:full_name) { [object.first_name, object.last_name].join " "}
  attribute(:practice_name) { object.meta.try(:practice).try(:name)}
  attribute(:practice_id) { object.meta.try(:practice).try(:id)}
  attribute(:user_type) { object.meta_type }

  attribute :reviewer_type do
    if object.meta_type == "Usr::Reviewer"
      object.meta.reviewer_type
    end
  end
end
