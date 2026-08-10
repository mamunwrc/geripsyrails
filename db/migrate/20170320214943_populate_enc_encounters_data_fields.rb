require_relative '../helpers/enc_encounter_migration_helpers'

class PopulateEncEncountersDataFields < ActiveRecord::Migration[5.0]
  def up
    EncEncounterMigrationHelpers.populate_data_fields!
  end

  def down
    # noop
  end
end
