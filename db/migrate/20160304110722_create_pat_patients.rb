class CreatePatPatients < ActiveRecord::Migration
  def change
    create_table :pat_patients do |t|
      t.string   :patient_code,          limit: 32
      t.string   :mrn,                   limit: 32
      t.string   :last_name,             limit: 256
      t.string   :first_name,            limit: 256
      t.string   :middle_name,           limit: 256
      t.string   :title,                 limit: 32
      t.string   :suffix,                limit: 32
      t.string   :ssn,                   limit: 16
      t.datetime :dob
      t.string   :status,                limit: 8
      t.string   :privacy_status,        limit: 32
      t.string   :ethnicity,             limit: 32
      t.string   :race,                  limit: 64
      t.string   :language,              limit: 64
      t.string   :marital_status,        limit: 64
      t.string   :release_information,   limit: 64
      t.datetime :death_date
      t.string   :occupation,            limit: 256
      t.string   :employer,              limit: 256
      t.string   :employment_status,     limit: 16
      t.string   :primary_provider_code, limit: 64
      t.integer  :facility_id
      t.text     :note
      t.text     :xml_data

      t.timestamps null: false
    end

    add_index :pat_patients, :dob
    add_index :pat_patients, :mrn
    add_index :pat_patients, :ssn
    add_index :pat_patients, :facility_id
  end
end
