class Enc::Encounter90853
  extend Enc::Encounter907xx::BaseMethods

  class << self
    def build_encounter_data(enc_data)
      enc_data.tap {|data|
        data.referral ||= Hashie::Mash.new
        data.referral.covering = nil
      }
    end
  end
end
