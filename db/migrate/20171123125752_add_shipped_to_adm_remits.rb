class AddShippedToAdmRemits < ActiveRecord::Migration[5.1]
  def change
    add_column :adm_remits, :shipped, :boolean, default: false
  end
end
