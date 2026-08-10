class AddHpAltPosCodeToAdmFacilities < ActiveRecord::Migration[5.1]
  def change
    add_column :adm_facilities, :hp_alt_pos_code, :integer
  end
end
