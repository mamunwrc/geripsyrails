require_relative '../helpers/pat_patient_migration_helpers'

class FixPatDobs < ActiveRecord::Migration[5.0]
  def change
    PatPatientMigrationHelpers.fix_dates!
  end
end
