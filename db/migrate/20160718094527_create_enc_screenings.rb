class CreateEncScreenings < ActiveRecord::Migration[5.0]
  def change
    create_table :enc_screenings do |t|
      t.json :axes
      t.integer :screening_type
      t.integer :encounter_id

      t.timestamps
    end
    add_index :enc_screenings, :screening_type
    add_index :enc_screenings, :encounter_id
  end
end
