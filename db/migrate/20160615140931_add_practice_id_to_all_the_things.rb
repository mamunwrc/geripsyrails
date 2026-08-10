class AddPracticeIdToAllTheThings < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_facilities, :practice_id, :integer
    add_column :usr_users, :practice_id, :integer
    add_column :usr_providers, :practice_id, :integer
    add_column :usr_admins, :practice_id, :integer
    add_column :usr_reviewers, :practice_id, :integer
    add_column :pat_patients, :practice_id, :integer

    add_index :adm_facilities, :practice_id
    add_index :usr_users, :practice_id
    add_index :usr_providers, :practice_id
    add_index :usr_admins, :practice_id
    add_index :usr_reviewers, :practice_id
    add_index :pat_patients, :practice_id
  end
end
