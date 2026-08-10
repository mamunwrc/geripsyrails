class Enc::EncounterAssessment < ApplicationRecord
  audited
  validates_presence_of :encounter_id
end
