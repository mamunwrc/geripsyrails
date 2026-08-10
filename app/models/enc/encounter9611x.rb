class Enc::Encounter9611x
  extend Enc::Encounter907xx::BaseMethods

  class << self
    def build_encounter_data(enc_data=nil)
      enc_data.tap {|data|
        data.referral = Hashie::Mash.new
        data.background_history = Hashie::Mash.new
        data.functional_status = Hashie::Mash.new
      }
    end
  end
end

