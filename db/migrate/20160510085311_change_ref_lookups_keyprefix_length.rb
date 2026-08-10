class ChangeRefLookupsKeyprefixLength < ActiveRecord::Migration[5.0]
  def change
    change_column :ref_lookups, :keyprefix, :string, limit: 32
  end
end
