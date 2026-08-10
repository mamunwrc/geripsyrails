class CreateRefPlaceOfServices < ActiveRecord::Migration
  def change
    create_table :ref_place_of_services do |t|
      t.string   :code,            limit: 2,                    null: false
      t.string   :name,            limit: 64,                   null: false
      t.string   :description,     limit: 4096
      t.datetime :effective_date
      t.datetime :expiration_date
      t.boolean  :is_common,                    default: false, null: false

      t.timestamps null: false
    end

    add_index :ref_place_of_services, :code
  end
end
