class AddSignedToEncEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_encounters, :signed_on, :datetime
    add_column :enc_encounters, :signed_by, :integer
  end
end
