class CreateRefIcds < ActiveRecord::Migration
  def change
    create_table :ref_icds do |t|
      t.string   :icd,               limit: 7,                     null: false
      t.string   :icd9,              limit: 6
      t.string   :order_num,         limit: 5
      t.string   :is_header,         limit: 1,     default: 0,   null: false
      t.string   :short_description, limit: 60
      t.text     :description
      t.boolean  :is_active,                       default: true
      t.datetime :effective_date
      t.datetime :expiration_date
      t.boolean  :is_common,                       default: false, null: false

      t.timestamps null: false
    end

    add_index :ref_icds, :icd
  end
end
