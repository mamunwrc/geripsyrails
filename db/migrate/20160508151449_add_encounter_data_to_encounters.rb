class AddEncounterDataToEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_encounters, :encounter_data, :text
  end
end
