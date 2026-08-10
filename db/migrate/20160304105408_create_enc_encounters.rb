class CreateEncEncounters < ActiveRecord::Migration
  def change
    create_table :enc_encounters do |t|
      t.integer :patient_id
      t.integer :provider_id
      t.integer :facility_id
      t.string :cpt_encounter_code, limit: 5
      t.string :place_of_service_code, limit: 2
      t.string :encounter_code, limit: 32
      t.string :encounter_title, limit: 256
      t.string :encounter_type, limit: 256
      t.string :chief_complaint, limit: 256
      t.string :encounter_status, limit: 12
      t.integer :encounter_duration
      t.datetime :encounter_start
      t.datetime :encounter_end
      t.boolean :confidentiality
      t.string :location, limit: 256
      t.integer :recorded_by
      t.datetime :recorded_on
      t.text :note
      t.text :xml_data

      t.timestamps null: false
    end
    add_index :enc_encounters, :patient_id
    add_index :enc_encounters, :provider_id
  end
end
