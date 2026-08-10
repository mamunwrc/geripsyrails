class PopulatePatPatientsNextTp < ActiveRecord::Migration[5.0]
  def change
    Pat::Patient.all.each(&:assign_next_tp)
  end
end
