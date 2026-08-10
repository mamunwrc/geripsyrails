class AddIncidentToProviderIdToPatPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :pat_patients, :incident_to_provider_id, :integer
  end
end
