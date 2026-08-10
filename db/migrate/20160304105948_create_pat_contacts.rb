class CreatePatContacts < ActiveRecord::Migration
  def change
    create_table :pat_contacts do |t|
      t.integer  :patient_id
      t.integer  :contact_type
      t.string   :first_name,      limit: 64
      t.string   :last_name,       limit: 64
      t.string   :address1,        limit: 64
      t.string   :address2,        limit: 64
      t.string   :city,            limit: 64
      t.string   :state,           limit: 3
      t.string   :zip,             limit: 15
      t.string   :title,           limit: 32
      t.string   :suffix,          limit: 32
      t.string   :ssn,             limit: 16
      t.datetime :dob
      t.string   :status,          limit: 8
      t.string   :home_phone,      limit: 16
      t.string   :work_phone,      limit: 16
      t.string   :fax,             limit: 16
      t.string   :cell,            limit: 16
      t.string   :alternate_phone, limit: 16
      t.string   :email,           limit: 12
      t.text     :xml_data

      t.timestamps null: false
    end

    add_index :pat_contacts, [:patient_id, :contact_type]
  end
end
