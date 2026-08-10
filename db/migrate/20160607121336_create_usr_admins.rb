class CreateUsrAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :usr_admins do |t|

      t.timestamps
    end
  end
end
