class AddConfidentialToGrpPatientNotes < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_patient_notes, :confidential, :boolean, default: false
  end
end
