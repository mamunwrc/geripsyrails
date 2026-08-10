class AddGroupToRefIcds < ActiveRecord::Migration[5.0]
  def up
    add_column :ref_icds, :group, :integer
    change_column :ref_icds, :icd, :string, length: 10
  end

  def down
    remove_column :ref_icds, :group, :integer
    change_column :ref_icds, :icd, :string, length: 7
  end
end
