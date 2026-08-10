class AddMissingIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :pat_patients, [:last_name, :first_name]
    add_index :pat_patients, :first_name
  end
end
