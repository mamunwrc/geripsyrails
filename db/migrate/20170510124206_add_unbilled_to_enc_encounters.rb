class AddUnbilledToEncEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_encounters, :unbilled, :boolean, default: false
  end
end
