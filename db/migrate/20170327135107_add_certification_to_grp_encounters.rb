class AddCertificationToGrpEncounters < ActiveRecord::Migration[5.0]
  def change
    add_column :grp_encounters, :certification, :json, default: {}
  end
end
