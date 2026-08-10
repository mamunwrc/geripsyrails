class AddFacilityPosCodeToPatPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :pat_patients, :facility_pos_code, :integer, default: 31
  end
end
