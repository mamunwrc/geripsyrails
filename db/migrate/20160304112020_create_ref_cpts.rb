class CreateRefCpts < ActiveRecord::Migration
  def change
    create_table :ref_cpts do |t|

      t.string   :cpt,             limit: 5,                    null: false
      t.string   :description,     limit: 2048
      t.integer  :allotted_time,   limit: 4,    default: 0
      t.boolean  :is_active,                    default: true
      t.string   :detail,          limit: 2048
      t.datetime :effective_date
      t.datetime :expiration_date
      t.boolean  :rx
      t.boolean  :is_common,                    default: false, null: false

      t.timestamps null: false
    end

    add_index :ref_cpts, :cpt
  end
end
