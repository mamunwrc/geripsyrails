class AddSignedToGrpEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_encounters, :signed_on, :date
    add_column :grp_encounters, :signed_by, :integer
    add_index :grp_encounters, :signed_by
  end
end
