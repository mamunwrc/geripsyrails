class CreatePatSurgicalHistories < ActiveRecord::Migration
  def change
    create_table :pat_surgical_histories do |t|

      t.string   :patient_code,         limit: 32
      t.integer  :encounter_id
      t.integer  :provider_id
      t.string   :sno_code,             limit: 18
      t.string   :icd_code,             limit: 8
      t.string   :cpt_code,             limit: 6
      t.string   :description,          limit: 255
      t.text     :diagnosis
      t.string   :category,             limit: 255
      t.string   :provider_name,         limit: 255
      t.datetime :begin_date
      t.boolean  :is_begin_date_approx
      t.datetime :end_date
      t.boolean  :is_end_date_approx
      t.text     :comment
      t.string   :status,               limit: 12
      t.boolean  :is_confidential
      t.integer  :rank,                 limit: 4
      t.string   :severity,             limit: 256
      t.string   :stability,            limit: 256
      t.integer  :recorded_by,          limit: 4
      t.datetime :recorded_on
      t.text     :xml_data

      t.timestamps null: false
    end
  end
end
