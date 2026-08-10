class CreateGrpAddendums < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_addendums do |t|
      t.text :note
      t.integer :encounter_id
      t.integer :user_id

      t.timestamps
    end
  end
end
