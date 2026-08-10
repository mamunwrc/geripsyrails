class AddMetaToUsrUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :usr_users, :meta_id, :integer
    add_column :usr_users, :meta_type, :string

    add_index :usr_users, [:meta_id, :meta_type]
  end
end
