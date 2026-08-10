class AddPriorAuthorizationNumberToPatPatients < ActiveRecord::Migration[5.1]
  def change
    change_table(:pat_patients) do |t|
      t.text :prior_authorization_number
    end
  end
end
