class AddShippedHpBillingToEncEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_encounters, :shipped_hp_billing, :text, default: nil
  end
end
