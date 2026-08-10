class AddDefaultStatusToPatient < ActiveRecord::Migration[5.0]
  def up
    change_column_default :pat_patients, :status, 0
  end

  def down
    up
  end
end
