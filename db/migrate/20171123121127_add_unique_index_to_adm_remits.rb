class AddUniqueIndexToAdmRemits < ActiveRecord::Migration[5.1]
  def change
    add_index :adm_remits, [:posted_on, :batch], unique: true
  end
end
