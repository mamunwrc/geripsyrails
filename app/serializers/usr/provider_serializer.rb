class Usr::ProviderSerializer < ActiveModel::Serializer
  attributes :id, :tax_number, :full_name, :npi, :ptan, :medicaid_id, :tp_required, :hp_account, :hold_claims, :linked_provider_id

  attribute(:degree) { {name: object.degree, val: object.degree } }

  attribute(:incident_to_providers) do
    object.incident_to_providers.collect do |provider|
      { id: provider.id, full_name: provider.full_name }
    end
  end

  attribute(:linked_provider) do
    { id: object.linked_provider&.id, full_name: object.linked_provider&.full_name, degree: object.linked_provider&.degree }
  end

  has_many :licenses
  has_one :user

  has_many :patients

  class PatientSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :dob, :full_name, :gender, :status, :insurance
  end
end
