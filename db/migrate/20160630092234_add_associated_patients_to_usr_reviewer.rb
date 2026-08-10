class AddAssociatedPatientsToUsrReviewer < ActiveRecord::Migration[5.0]
  def change
    add_column :usr_reviewers, :associated_patients, :integer, array: true, default: []
    add_column :usr_reviewers, :associated_facilities, :integer, array: true, default: []
    add_column :usr_reviewers, :associated_providers, :integer, array: true, default: []
    add_column :usr_reviewers, :reviewer_type, :integer, default: 0

    add_index :usr_reviewers, :associated_patients, using: 'gin'
    add_index :usr_reviewers, :associated_facilities, using: 'gin'
    add_index :usr_reviewers, :associated_providers, using: 'gin'
  end
end
