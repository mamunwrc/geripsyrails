class EmbiggenFacilityPhoneNumber < ActiveRecord::Migration[5.0]
  def up
    change_column :adm_facilities, :home_phone, :string, limit: 32
    change_column :adm_facilities, :work_phone, :string, limit: 32
  end

  def down
    change_column :adm_facilities, :home_phone, :string, limit: 16
    change_column :adm_facilities, :work_phone, :string, limit: 16
  end
end
