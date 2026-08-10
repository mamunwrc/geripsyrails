class CreateJoinTablePatientsProviders < ActiveRecord::Migration[5.0]
  def change
    create_join_table :patients, :providers do |t|
      t.index [:patient_id, :provider_id]
      t.index [:provider_id, :patient_id]
    end
  end
end
