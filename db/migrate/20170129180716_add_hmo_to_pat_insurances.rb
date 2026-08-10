class AddHmoToPatInsurances < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_insurances, :medicare_hmo, :boolean, default: false
  end
end
