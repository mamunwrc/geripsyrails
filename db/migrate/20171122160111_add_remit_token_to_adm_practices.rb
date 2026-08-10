class AddRemitTokenToAdmPractices < ActiveRecord::Migration[5.1]
  def up
    add_column :adm_practices, :remit_token, :string
    add_index :adm_practices, :remit_token, unique: true
    Adm::Practice.all.each(&:regenerate_remit_token)
  end

  def down
    remove_index :adm_practices, :remit_token
    remove_column :adm_practices, :remit_token
  end
end
