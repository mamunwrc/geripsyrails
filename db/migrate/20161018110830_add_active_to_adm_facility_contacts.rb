class AddActiveToAdmFacilityContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :adm_facility_contacts, :active, :boolean, default: true
  end
end
