class AddInsuranceDataToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :insurance_data, :json
  end
end
