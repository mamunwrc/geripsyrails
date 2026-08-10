class DelShippedToHpToEncEncounters < ActiveRecord::Migration[5.0]
  def change
    remove_column :enc_encounters, :shipped_to_hp
  end
end
