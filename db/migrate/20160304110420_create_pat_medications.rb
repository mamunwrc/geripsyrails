class CreatePatMedications < ActiveRecord::Migration
  def change
    create_table :pat_medications do |t|
      t.integer  :patient_id
      t.integer  :encounter_id
      t.integer  :provider_id
      t.integer  :medicationType
      t.boolean  :is_administered
      t.integer  :administered_by_provider_id
      t.string   :administered_by_name,        limit: 64
      t.string   :medication_code,             limit: 64
      t.string   :NDC,                         limit: 11
      t.string   :description,                 limit: 255
      t.string   :dose_amount,                 limit: 32
      t.string   :dose_form,                   limit: 32
      t.string   :dose_frequency,              limit: 32
      t.string   :dose_frequencyUnit,          limit: 16
      t.string   :sig,                         limit: 255
      t.string   :pharmacy_instr,              limit: 255
      t.datetime :begin_date
      t.datetime :end_date
      t.string   :status,                      limit: 32
      t.string   :duration_length,             limit: 32
      t.string   :duration_unit,               limit: 16
      t.string   :dispense_qty,                limit: 32
      t.string   :dispense_qty_unit,           limit: 16
      t.boolean  :is_allow_substitute
      t.boolean  :refill
      t.text     :comment
      t.string   :deleted_reason,              limit: 255
      t.integer  :recorded_by,                 limit: 4
      t.datetime :recorded_on
      t.integer  :deleted_by
      t.datetime :deleted_on
      t.text     :xml_data

      t.timestamps null: false
    end

    add_index :pat_medications, :patient_id
  end
end
