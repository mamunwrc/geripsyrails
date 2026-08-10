class AddReviewerIdToAdmPractices < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_practices, :reviewer_id, :integer
    add_index :adm_practices, :reviewer_id
  end
end
