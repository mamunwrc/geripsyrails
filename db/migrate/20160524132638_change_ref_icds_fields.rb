class ChangeRefIcdsFields < ActiveRecord::Migration[5.0]
  def up
    change_column :ref_icds, :order_num, 'integer USING CAST("order_num" AS integer)', default: 9999
    remove_column :ref_icds, :is_header
    add_column :ref_icds, :is_header, :boolean, default: true
  end

  def down
    change_column :ref_icds, :order_num, :string
    change_column :ref_icds, :is_header, :string, default: "0"
  end
end
