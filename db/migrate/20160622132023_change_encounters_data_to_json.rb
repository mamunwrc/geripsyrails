class ChangeEncountersDataToJson < ActiveRecord::Migration[5.0]
  def up
    change_column :enc_encounters, :encounter_data, 'json USING CAST(encounter_data AS json)'
  end

  def down
    change_column :enc_encounters, :encounter_data, :text
  end

end
