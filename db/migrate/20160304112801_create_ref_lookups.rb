class CreateRefLookups < ActiveRecord::Migration
  def change
    create_table :ref_lookups do |t|
      t.string  :keyprefix, limit: 8,     null: false
      t.string  :keyname,   limit: 32
      t.text    :keyvalue
      t.integer :rank,      limit: 2

      t.timestamps null: false
    end

    add_index :ref_lookups, [:keyprefix, :keyname]
  end
end
