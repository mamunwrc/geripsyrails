class AddHpCodeToPatInsurances < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_insurances, :hp_id_code, :integer
    add_index :pat_insurances, :hp_id_code
  end
end
