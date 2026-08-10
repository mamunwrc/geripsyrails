class AddFacilityPosCodeToEncEncounters < ActiveRecord::Migration[5.1]
  def change
    add_column :enc_encounters, :facility_pos_code, :integer
  end
end
