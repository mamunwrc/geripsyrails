class RenameClaimmdPayeridOnInsurances < ActiveRecord::Migration[5.1]
  def change
    rename_column :pat_insurances, :claimmd_payerid, :payerid
  end
end
