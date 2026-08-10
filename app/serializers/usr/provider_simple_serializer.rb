class Usr::ProviderSimpleSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :degree, :npi, :tp_required, :hold_claims, :linked_provider_id
end
