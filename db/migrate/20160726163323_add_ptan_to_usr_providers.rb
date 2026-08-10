class AddPtanToUsrProviders < ActiveRecord::Migration[5.0]
  def change
    add_column :usr_providers, :ptan, :string
  end
end
