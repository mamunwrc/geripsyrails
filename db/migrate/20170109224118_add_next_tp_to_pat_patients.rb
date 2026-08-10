class AddNextTpToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :next_tp, :datetime
  end
end
