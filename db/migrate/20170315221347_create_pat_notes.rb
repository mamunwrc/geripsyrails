class CreatePatNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :pat_notes do |t|
      t.references :patient
      t.references :user
      t.text       :text

      t.timestamps
    end
  end
end
