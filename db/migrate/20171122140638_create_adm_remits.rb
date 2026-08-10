class CreateAdmRemits < ActiveRecord::Migration[5.1]
  def change
    create_table :adm_remits do |t|
      t.datetime :posted_on
      t.integer :provider_id
      t.integer :status
      t.string :batch
      t.text :content

      t.timestamps
    end
  end
end
