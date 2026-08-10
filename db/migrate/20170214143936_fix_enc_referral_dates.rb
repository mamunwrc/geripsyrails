require_relative '../helpers/enc_encounter_migration_helpers'

class FixEncReferralDates < ActiveRecord::Migration[5.0]
  def change
    EncEncounterMigrationHelpers.fix_dates!
  end
end
