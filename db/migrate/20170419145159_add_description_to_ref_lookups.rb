class AddDescriptionToRefLookups < ActiveRecord::Migration[5.0]
  def change
    add_column :ref_lookups, :description, :string
  end
end
