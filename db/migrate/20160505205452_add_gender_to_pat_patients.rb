class AddGenderToPatPatients < ActiveRecord::Migration
  def change
    change_table(:pat_patients) do |t|
      t.integer :gender, default: 0
    end
  end
end
