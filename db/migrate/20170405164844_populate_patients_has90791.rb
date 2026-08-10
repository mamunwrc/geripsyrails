class PopulatePatientsHas90791 < ActiveRecord::Migration[5.0]
  def up
    patient_ids = Enc::Encounter.signed._90791s.pluck(:patient_id).uniq
    Pat::Patient.where(id: patient_ids).update_all(has90791: true)
  end

  def down
    Pat::Patient.update_all has90791: false
  end
end
