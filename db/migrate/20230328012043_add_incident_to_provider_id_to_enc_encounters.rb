class AddIncidentToProviderIdToEncEncounters < ActiveRecord::Migration[5.1]
  def change
    add_column :enc_encounters, :incident_to_provider_id, :integer
  end
end
