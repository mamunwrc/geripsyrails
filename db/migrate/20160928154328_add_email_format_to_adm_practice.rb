class AddEmailFormatToAdmPractice < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_practices, :email_format, :integer, default: 0
  end
end
