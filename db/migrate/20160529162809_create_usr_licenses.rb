class CreateUsrLicenses < ActiveRecord::Migration[5.0]
  def change
    create_table :usr_licenses do |t|
      t.integer :provider_id
      t.integer :number
      t.integer :state
      t.datetime :expiration

      t.timestamps
    end
  end
end
