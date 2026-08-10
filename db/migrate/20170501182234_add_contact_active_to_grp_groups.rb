class AddContactActiveToGrpGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_groups, :contact_active, :boolean, default: false
  end
end
