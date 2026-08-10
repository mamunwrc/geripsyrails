class AddTpRequiredToUsrProviders < ActiveRecord::Migration[5.0]
  def change
    add_column :usr_providers, :tp_required, :boolean, default: true
  end
end
