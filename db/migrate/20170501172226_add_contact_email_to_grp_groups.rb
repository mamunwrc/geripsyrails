class AddContactEmailToGrpGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_groups, :contact_email, :string
  end
end
