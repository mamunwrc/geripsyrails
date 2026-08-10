class CreateAdmFacilityDoctors < ActiveRecord::Migration[5.0]
  def change
    create_table :adm_facility_doctors do |t|
      t.string :name
      t.integer :facility_id

      t.timestamps
    end
    add_index :adm_facility_doctors, :facility_id
  end
end
