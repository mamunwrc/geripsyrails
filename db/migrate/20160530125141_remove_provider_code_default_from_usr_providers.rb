class RemoveProviderCodeDefaultFromUsrProviders < ActiveRecord::Migration[5.0]
  def up
    change_column :usr_providers, :provider_code, :string, null: true
  end

  def down
    change_column :usr_providers, :provider_code, :string, null: false
  end
end
