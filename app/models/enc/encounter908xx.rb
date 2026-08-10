class Enc::Encounter908xx
  extend Enc::Encounter907xx::BaseMethods

  class << self

  private

    def build_encounter_data(enc_data)
      enc_data.tap do |data|
        populate_referral! data
        populate_certification! data
        populate_problem! data
        populate_therapeutic_communication! data
        populate_diagnosis! data
        populate_background_history! data
        populate_progress! data
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
    end

    def populate_problem!(data)
      data.problem ||= Hashie::Mash.new

      # medical_necessity with key '12' does not exist in MAJORTARGETSYMPTOMS lookup
      if (mednec = data.referral.medical_necessity) and
          !mednec.blank? and !mednec.map{|mn| mn['name'] }.include?('12')
        data.problem.major_target_symptom = mednec
      end
    end

    def populate_functional_status!(data)
      data.functional_status ||= Hashie::Mash.new
      data.functional_status.status_changed = nope

      ic = data.functional_status.interactive_complexity
      if ic.try(:name) == 'N'
        ic.delete(:problems)
      elsif ic.try(:name) == 'Y' && Hash === ic.problems
        ic.problems = [ic.problems]
      end
    end

    def populate_certification!(data)
      data.certification = Hashie::Mash.new
    end

    def populate_therapeutic_communication!(data)
      data.therapeutic_communication ||= Hashie::Mash.new
      data.therapeutic_communication.family_present = nope
    end

    def populate_background_history!(data)
      data.background_history ||= Hashie::Mash.new

      data.background_history.status_changed    ||= nope
      data.background_history.meds_changed      ||= nope
      data.background_history.condition_changed ||= nope
      data.background_history.note              ||= data.problem.observation
    end

    def populate_diagnosis!(data)
      data.diagnosis ||= Hashie::Mash.new

      data.diagnosis.session_goals_prev = data.diagnosis.session_goals
      data.diagnosis.session_goals = nil
    end

    def populate_progress!(data)
      data.progress ||= Hashie::Mash.new

      data.progress.notes_prev = data.progress.notes
      data.progress.notes = nil
    end

  end
end
