class AddHas90791ToPatPatients < ActiveRecord::Migration[5.0]
  def change
    add_column :pat_patients, :has90791, :boolean, default: false
  end
end
