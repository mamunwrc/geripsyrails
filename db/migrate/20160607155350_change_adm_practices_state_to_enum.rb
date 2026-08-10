class ChangeAdmPracticesStateToEnum < ActiveRecord::Migration[5.0]
  def up
    remove_column :adm_practices, :state
    add_column :adm_practices, :state, :integer
  end

  def down
    remove_column :adm_practices, :state
    add_column :adm_practices, :state, :string, limit: 3
  end
end
