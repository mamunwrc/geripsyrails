class CreateJoinTableFacilitiesPractices < ActiveRecord::Migration[5.0]
  def change
    create_join_table :facilities, :practices do |t|
      t.index [:facility_id, :practice_id]
      t.index [:practice_id, :facility_id]
    end
  end
end
