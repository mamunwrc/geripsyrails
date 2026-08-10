class AddInsuranceColsToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :primary_insurance_id, :integer
    add_index :pat_patients, :primary_insurance_id
    add_column :pat_patients, :secondary_insurance_id, :integer
    add_index :pat_patients, :secondary_insurance_id
    add_column :pat_patients, :tertiary_insurance_id, :integer
    add_index :pat_patients, :tertiary_insurance_id

    add_column :pat_patients, :primary_insurance_number, :string
    add_column :pat_patients, :secondary_insurance_number, :string
    add_column :pat_patients, :tertiary_insurance_number, :string
  end
end
