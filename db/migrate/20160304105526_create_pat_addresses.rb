class CreatePatAddresses < ActiveRecord::Migration
  def change
    create_table :pat_addresses do |t|
      t.integer :patient_id
      t.string  :patient_code,    limit: 32
      t.string  :address_type,     limit: 32
      t.integer :address_rank,     limit: 4
      t.string  :address1,        limit: 64
      t.string  :address2,        limit: 64
      t.string  :city,            limit: 64
      t.string  :state,           limit: 3
      t.string  :zip,             limit: 15
      t.string  :home_phone,      limit: 16
      t.string  :work_phone,      limit: 16
      t.string  :fax,             limit: 16
      t.string  :cell,            limit: 16
      t.string  :alternate_phone, limit: 16
      t.string  :email,           limit: 12
      t.text    :xml_data

      t.timestamps null: false
    end

    add_index :pat_addresses, [:patient_id, :address_type]
  end
end
