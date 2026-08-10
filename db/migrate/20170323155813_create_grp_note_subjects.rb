class CreateGrpNoteSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_note_subjects do |t|
      t.integer :patient_note_id
      t.integer :patient_id

      t.timestamps
    end
    add_index :grp_note_subjects, :patient_note_id
    add_index :grp_note_subjects, :patient_id
  end
end
