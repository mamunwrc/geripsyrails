class AddTaxNumberToAdmPractices < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_practices, :tax_number, :string, limit: 30
  end
end
