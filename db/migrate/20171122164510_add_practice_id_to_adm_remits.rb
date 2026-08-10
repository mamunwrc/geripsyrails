class AddPracticeIdToAdmRemits < ActiveRecord::Migration[5.1]
  def change
    add_column :adm_remits, :practice_id, :integer
    add_index :adm_remits, :practice_id
  end
end
