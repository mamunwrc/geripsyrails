class AddRemitBatchIdToAdmRemits < ActiveRecord::Migration[5.1]
  def change
    add_column :adm_remits, :remit_batch_id, :integer
    add_index :adm_remits, :remit_batch_id
  end
end
