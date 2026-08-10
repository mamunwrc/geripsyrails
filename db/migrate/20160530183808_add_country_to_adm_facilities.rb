class AddCountryToAdmFacilities < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_facilities, :country, :string
  end
end
