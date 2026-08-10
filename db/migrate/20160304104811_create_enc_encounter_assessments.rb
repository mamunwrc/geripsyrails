class CreateEncEncounterAssessments < ActiveRecord::Migration
  def change
    create_table :enc_encounter_assessments do |t|
      t.integer :encounter_id, null: false
      t.string :sno_code, limit: 18
      t.string :icd_code, limit: 8
      t.string :description, limit: 256
      t.string :assessment_status, limit: 32
      t.string :category, limit: 64
      t.text :comment
      t.integer :provider_id
      t.integer :recorded_by
      t.datetime :recorded_on
      t.integer :category_rank
      t.integer :assessment_rank
      t.text :xml_data

      t.timestamps null: false
    end
    add_index :enc_encounter_assessments, :encounter_id
  end
end
