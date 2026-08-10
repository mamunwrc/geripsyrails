class CreateUsrProviders < ActiveRecord::Migration
  def change
    create_table :usr_providers do |t|
      t.integer "user_id", limit: 4
      t.string "provider_code", limit: 32, null: false
      t.string "external_provider_code", limit: 32
      t.string "degree", limit: 20
      t.string "position", limit: 256
      t.string "speciality_license_number", limit: 30
      t.string "medical_license_number", limit: 30
      t.string "tax_number", limit: 30
      t.string "status", limit: 16, null: false
      t.string "dea_number", limit: 10
      t.string "dea_extension", limit: 20
      t.string "upin", limit: 24
      t.string "npi", limit: 10
      t.string "medicare_id", limit: 32
      t.string "medicaid_id", limit: 32
      t.string "hmo_id", limit: 32
      t.string "bank_account_number", limit: 32
      t.string "bank_routing_number", limit: 32
      t.boolean "can_prescribe", default: false
      t.text "xml_data"

      t.timestamps null: false
    end

    add_index :usr_providers, :user_id
  end
end
