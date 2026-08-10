class CreatePatInsurances < ActiveRecord::Migration[5.0]
  def change
    create_table :pat_insurances do |t|
      t.string :name

      t.timestamps
    end
  end
end
