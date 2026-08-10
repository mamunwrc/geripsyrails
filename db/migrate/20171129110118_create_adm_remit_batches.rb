class CreateAdmRemitBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :adm_remit_batches do |t|
      t.datetime :batch_date
      t.jsonb :payload
      t.inet :ip
      t.integer :practice_id
      t.string :token

      t.timestamps
    end
    add_index :adm_remit_batches, :practice_id
  end
end
