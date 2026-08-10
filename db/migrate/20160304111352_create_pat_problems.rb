class CreatePatProblems < ActiveRecord::Migration
  def change
    create_table :pat_problems do |t|
      t.integer  :patient_id,            limit: 4,     null: false
      t.integer  :encounter_id,          limit: 4
      t.integer  :provider_id,           limit: 4
      t.string   :problem_category,      limit: 32
      t.string   :sno_code,              limit: 18
      t.string   :icd_code,              limit: 8
      t.string   :description,           limit: 255
      t.string   :status,                limit: 12
      t.datetime :problem_status_date
      t.boolean  :is_status_date_approx
      t.string   :diagnosed_by,          limit: 255
      t.string   :diagnosed_provider_id, limit: 255
      t.datetime :begin_date
      t.boolean  :is_begin_date_approx
      t.datetime :end_date
      t.boolean  :is_end_date_approx
      t.text     :comment
      t.boolean  :is_confidential
      t.string   :terminate_reason,      limit: 255
      t.string   :chronicity,            limit: 3
      t.integer  :recorded_by,           limit: 4
      t.datetime :recorded_on
      t.integer  :deleted_by,            limit: 4
      t.datetime :deleted_on
      t.text     :xml_data

      t.timestamps null: false
    end

    add_index :pat_problems, :patient_id
  end
end
