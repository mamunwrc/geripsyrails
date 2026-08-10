class AddPracticeIdToGrpGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_groups, :practice_id, :integer
    add_index :grp_groups, :practice_id
  end
end
