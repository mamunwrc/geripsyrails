class StringifyProvidersDegree < ActiveRecord::Migration[5.0]
  def up
    remove_column :usr_providers, :degree
    add_column :usr_providers, :degree, :string
  end

  def down
    remove_column :usr_providers, :degree
    add_column :usr_providers, :degree, :integer
  end
end
