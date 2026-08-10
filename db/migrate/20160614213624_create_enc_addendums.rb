class CreateEncAddendums < ActiveRecord::Migration[5.0]
  def change
    create_table :enc_addendums do |t|
      t.text :note
      t.integer :encounter_id

      t.timestamps
    end
    add_index :enc_addendums, :encounter_id
  end
end
