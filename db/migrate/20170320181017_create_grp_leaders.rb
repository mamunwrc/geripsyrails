class CreateGrpLeaders < ActiveRecord::Migration[5.0]
  def change
    create_table :grp_leaders do |t|
      t.integer :provider_id, index: true
      t.integer :group_id, index: true

      t.timestamps
    end
  end
end
