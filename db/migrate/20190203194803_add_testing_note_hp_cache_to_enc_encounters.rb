class AddTestingNoteHpCacheToEncEncounters < ActiveRecord::Migration[5.1]
  def change
    add_column :enc_encounters, :testing_note_hp_cache, :jsonb, default: {files: []}
  end
end
