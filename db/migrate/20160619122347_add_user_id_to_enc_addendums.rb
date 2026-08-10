class AddUserIdToEncAddendums < ActiveRecord::Migration[5.0]
  def change
    add_column :enc_addendums, :user_id, :integer
  end
end
