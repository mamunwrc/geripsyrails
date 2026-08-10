class AddCodeModifiersToEncEncounters < ActiveRecord::Migration[5.1]
  def change
    add_column :enc_encounters, :code_modifier, :integer
  end
end
