class AddRoomNumToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :room_num, :string
  end
end
