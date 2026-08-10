class AddProviderIdToGrpEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_encounters, :provider_id, :integer
  end
end
