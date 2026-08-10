class AddIncidentToToUsrProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :usr_providers, :incident_to_provider_id, :integer, default: nil
  end
end
