class AddClaimmdPayeridToInsurances < ActiveRecord::Migration[5.1]
  def change
    add_column :pat_insurances, :claimmd_payerid, :text
  end
end
