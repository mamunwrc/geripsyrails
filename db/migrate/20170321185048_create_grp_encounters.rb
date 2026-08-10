class CreateGrpEncounters < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_encounters do |t|
      t.integer :group_id
      t.json :group_therapy_session
      t.json :interventions

      t.timestamps
    end
    add_index :grp_encounters, :group_id
  end
end
