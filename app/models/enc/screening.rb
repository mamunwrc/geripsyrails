class Enc::Screening < ApplicationRecord
  audited

  enum screening_type: %i(bcrs)

  belongs_to :encounter
end
