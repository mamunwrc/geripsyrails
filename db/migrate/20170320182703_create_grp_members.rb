class CreateGrpMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_members do |t|
      t.integer :group_id, index: true
      t.integer :patient_id, index: true
      t.timestamps
    end
  end
end
