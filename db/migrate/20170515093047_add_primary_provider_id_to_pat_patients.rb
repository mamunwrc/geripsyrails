class AddPrimaryProviderIdToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :primary_provider_id, :integer
    add_index :pat_patients, :primary_provider_id
  end
end
