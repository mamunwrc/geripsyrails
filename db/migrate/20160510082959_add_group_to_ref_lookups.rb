class AddGroupToRefLookups < ActiveRecord::Migration[5.0]
  def change
    add_column :ref_lookups, :group, :string
  end
end
