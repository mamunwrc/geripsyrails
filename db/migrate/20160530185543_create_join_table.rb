class CreateJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :users, :practices do |t|
      t.index [:user_id, :practice_id]
      t.index [:practice_id, :user_id]
    end
  end
end
