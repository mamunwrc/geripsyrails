class PopulatePrimaryProvider < ActiveRecord::Migration[5.0]
  def up
    Pat::Patient.all.each do |patient|
      if enc = patient.encounters.signed.last
        patient.update_primary_provider enc.cpt_encounter_code, false, enc.signed_by
      end
    end
  end

  def down
    Pat::Patient.update_all primary_provider_id: nil
  end
end
