class Enc::Encounter907xx

  module BaseMethods
    def create_from(reference, default_attrs)
      enc_data =
        if reference.blank?
          Hashie::Mash.new
        else
          Hashie::Mash.new(Hash[
            Enc::Encounter::DATA_FIELDS.
              map{|f| [f, reference.send(f).to_h] }
          ])
        end

      enc_data = build_encounter_data(enc_data).to_h
      Enc::Encounter.create(default_attrs.merge(enc_data))
    end

  protected

    def nameval(name, val)
      {name: name, val: val}
    end

    def now(tz="US/Eastern")
      Time.now.in_time_zone(tz).midnight.utc.midnight
    end

    def nope
      nameval('N', 'No')
    end

  end

  extend BaseMethods

  class << self

  private

    def build_encounter_data(enc_data)
      enc_data.tap do |data|
        populate_referral! data
        populate_background_history! data
        populate_functional_status! data
      end
    end

    def populate_referral!(data)
      data.referral ||= Hashie::Mash.new
      data.referral.service_date = now
      data.referral.covering = nil

      if data.referral.order_date.blank?
        data.referral.order_date = now
      end

      data.referral.hiatus = nope
      data.referral.hiatus_reason &&= nil
      data.referral.hiatus_date &&= nil
      data.referral.hiatus_comment &&= nil

    end

    def populate_background_history!(data)
      data.background_history ||= Hashie::Mash.new
 
      data.background_history.birth_place       ||= nameval("1", 'United States - local')
      data.background_history.family_background ||= nameval("1", 'Intact, traditional family')
      data.background_history.raised_by         ||= nameval("1", 'natural parents')
      data.background_history.hist_mental_ill   ||= nameval("NONE", 'None')
      data.background_history.onpsychmeds       ||= nameval("U", 'Unknown')
    end

    def populate_functional_status!(data)
      data.functional_status ||= Hashie::Mash.new

      data.functional_status.orientation            ||= nameval('O', 'Orientation x3')
      data.functional_status.appearance             ||= nameval("A", 'Appropriate')
      data.functional_status.motor                  ||= nameval("N", 'Normal')
      data.functional_status.alertness              ||= nameval("1", 'Adequately alert/attentive')
      data.functional_status.mood                   ||= nameval("N", 'Normal')
      data.functional_status.affect                 ||= nameval("G", 'Appropriate')
      data.functional_status.expression             ||= nameval("G", 'Good')
      data.functional_status.attitude               ||= nameval("G", 'Normal')
      data.functional_status.harm                   ||= nameval("N", 'No')
      data.functional_status.interactive_complexity ||= nameval("N", 'No')
      data.functional_status.reasoning              ||= nameval("1", 'Good')
      data.functional_status.motivation             ||= nameval("1", 'Good')
      data.functional_status.thought_process        ||= nameval("1", 'Normal')
      data.functional_status.thought_content        ||= nameval("N", 'Normal')
      data.functional_status.recall                 ||= nameval("1", 'Unimpaired: capable of recalling encounter session-session')
      data.functional_status.intellectual_ability   ||= nameval("1", 'Average')
      data.functional_status.insight                ||= nameval("1", 'Good')
    end

  end
end
