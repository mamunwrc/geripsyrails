class AddClaimMdEnabledToProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :usr_providers, :claim_md_enabled, :boolean, default: false
  end
end
