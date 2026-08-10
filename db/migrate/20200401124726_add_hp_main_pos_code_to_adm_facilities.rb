class AddHpMainPosCodeToAdmFacilities < ActiveRecord::Migration[5.1]
  def change
    add_column :adm_facilities, :hp_main_pos_code, :integer
  end
end
