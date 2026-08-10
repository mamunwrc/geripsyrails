class AddAddressColumnsToPatInsurances < ActiveRecord::Migration[5.1]
  def change
    add_column :pat_insurances, :address1, :string
    add_column :pat_insurances, :address2, :string
    add_column :pat_insurances, :city, :string
    add_column :pat_insurances, :state, :string
    add_column :pat_insurances, :zip, :string
  end
end
