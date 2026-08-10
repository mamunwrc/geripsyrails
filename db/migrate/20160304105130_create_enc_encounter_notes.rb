class CreateEncEncounterNotes < ActiveRecord::Migration
  def change
    create_table :enc_encounter_notes do |t|
      t.integer :encounter_id
      t.integer :patient_id
      t.integer :provider_id
      t.integer :note_type
      t.string :note_status, limit: 16
      t.integer :template_id
      t.string :note_section_type, limit: 32
      t.integer :note_section_seq
      t.text :note

      t.timestamps null: false
    end
    add_index :enc_encounter_notes, :encounter_id
    add_index :enc_encounter_notes, :patient_id
    add_index :enc_encounter_notes, :provider_id
  end
end
