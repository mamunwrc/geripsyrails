class AddShippedToHpToEncEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_encounters, :shipped_to_hp, :boolean, default: false
  end
end
