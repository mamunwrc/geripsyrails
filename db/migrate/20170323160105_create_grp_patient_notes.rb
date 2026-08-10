class CreateGrpPatientNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_patient_notes do |t|
      t.integer :encounter_id
      t.string :body

      t.timestamps
    end
    add_index :grp_patient_notes, :encounter_id
  end
end
