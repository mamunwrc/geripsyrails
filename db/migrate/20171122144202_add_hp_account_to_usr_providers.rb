class AddHpAccountToUsrProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :usr_providers, :hp_account, :integer
  end
end
