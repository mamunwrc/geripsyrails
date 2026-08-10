class GiveDefaultToAdmPracticesPracticeType < ActiveRecord::Migration[5.0]
  def up
    change_column :adm_practices, :practice_type, :integer, default: 0
  end

  def down
    change_column :adm_practices, :practice_type, :integer, default: nil
  end
end
