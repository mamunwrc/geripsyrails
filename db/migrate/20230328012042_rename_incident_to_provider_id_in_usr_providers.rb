class RenameIncidentToProviderIdInUsrProviders < ActiveRecord::Migration[5.1]
  def change
    rename_column :usr_providers, :incident_to_provider_id, :linked_provider_id
  end
end
