class AddHoldClaimsToUsrProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :usr_providers, :hold_claims, :boolean, default: false
  end
end
