class AddTimezoneToUsrUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :usr_users, :timezone, :integer, default: 0
  end
end
