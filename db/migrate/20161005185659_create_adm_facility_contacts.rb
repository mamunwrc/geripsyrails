class CreateAdmFacilityContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :adm_facility_contacts do |t|
      t.integer :export_format, default: 0
      t.integer :export_type, default: 0
      t.integer :facility_id
      t.string :name
      t.string :email

      t.timestamps
    end
    add_index :adm_facility_contacts, :facility_id
  end
end
