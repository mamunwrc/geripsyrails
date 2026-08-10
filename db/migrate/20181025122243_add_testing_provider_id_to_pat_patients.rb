class AddTestingProviderIdToPatPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :pat_patients, :testing_provider_id, :integer
  end
end
