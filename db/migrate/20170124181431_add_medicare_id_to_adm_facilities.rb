class AddMedicareIdToAdmFacilities < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_facilities, :medicare, :integer, default: 1
    add_index :adm_facilities, :medicare
  end
end
