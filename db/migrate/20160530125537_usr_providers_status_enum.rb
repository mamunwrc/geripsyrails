class UsrProvidersStatusEnum < ActiveRecord::Migration[5.0]
  def up
    remove_column :usr_providers, :status
    add_column :usr_providers, :status, :integer, default: 0
  end

  def down
    remove_column :usr_providers, :status
    add_column :usr_providers, :status, :string, limit: 16, null: false
  end
end
