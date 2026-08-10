class CreatePatDocuments < ActiveRecord::Migration
  def change
    create_table :pat_documents do |t|
      t.integer  :patient_id
      t.integer  :provider_id
      t.string   :folder_name,          limit: 255
      t.string   :document_name,        limit: 255
      t.string   :document_description, limit: 1024
      t.datetime :document_date
      t.string   :directory,            limit: 255
      t.string   :file_name,            limit: 255
      t.binary   :contents

      t.timestamps null: false
    end

    add_index :pat_documents, [:folder_name, :document_name]
    add_index :pat_documents, :patient_id
    add_index :pat_documents, :provider_id
  end
end
