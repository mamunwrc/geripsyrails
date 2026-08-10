class BreakupEncEncountersEncounterData < ActiveRecord::Migration[5.0]
  def change
    Enc::Encounter::DATA_FIELDS.each do |col| 
      add_column :enc_encounters, col, :json
    end
  end
end
