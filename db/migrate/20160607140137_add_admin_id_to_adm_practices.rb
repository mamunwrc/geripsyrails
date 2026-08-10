class AddAdminIdToAdmPractices < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_practices, :admin_id, :integer
    add_index :adm_practices, :admin_id
  end
end
