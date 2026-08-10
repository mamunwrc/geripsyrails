class CreateAdmFacilities < ActiveRecord::Migration
  def change
    create_table :adm_facilities do |t|
      t.string :name, limit: 32
      t.integer :facility_type
      t.string :admin_last_name, limit: 64
      t.string :admin_first_name, limit: 64
      t.string :admin_middle_name, limit: 64
      t.string :admin_title, limit: 32
      t.string :admin_email, limit: 256
      t.string :suffix, limit: 32
      t.string :address1, limit: 64
      t.string :address2, limit: 64
      t.string :city, limit: 64
      t.string :state, limit: 3
      t.string :zip, limit: 15
      t.string :home_phone, limit: 16
      t.string :work_phone, limit: 16
      t.string :email, limit: 256
      t.string :npi, limit: 12
      t.boolean :send_alerts, default: false
      t.string :status, limit: 8
      t.text :xml_data

      t.timestamps null: false
    end
  end
end
