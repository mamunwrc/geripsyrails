class CreatePatPfsHistories < ActiveRecord::Migration
  def change
    create_table :pat_pfs_histories do |t|
      t.integer  :patient_id, null: false
      t.integer  :encounter_id
      t.integer  :provider_id
      t.integer  :history_type, null: false
      t.string   :sno_code,                 limit: 18
      t.string   :icd_code,                 limit: 8
      t.string   :cpt_code,                 limit: 6
      t.string   :description,              limit: 255
      t.string   :category,                 limit: 255
      t.string   :provider_name,            limit: 255
      t.datetime :begin_date
      t.boolean  :is_begin_date_approx
      t.datetime :end_date
      t.boolean  :is_end_date_approx
      t.text     :comment
      t.string   :status,                   limit: 12
      t.boolean  :is_confidential
      t.string   :terminate_reason,         limit: 255
      t.string   :relationship_sno_code,    limit: 18
      t.string   :relationship_description, limit: 255
      t.boolean  :is_deceased
      t.integer  :family_member_age,        limit: 4
      t.string   :family_member_name,       limit: 256
      t.string   :family_member_age_death,  limit: 32
      t.datetime :family_member_birth_date
      t.integer  :recorded_by,              limit: 4
      t.datetime :recorded_on
      t.integer  :deleted_by,               limit: 4
      t.datetime :deleted_on
      t.text     :xml_data

      t.timestamps null: false
    end

    add_index :pat_pfs_histories, :patient_id
  end
end
