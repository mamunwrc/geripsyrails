class Enc::EncounterGBH1
  extend Enc::Encounter907xx::BaseMethods

  class << self

  private

    def build_encounter_data(enc_data)
      enc_data.tap do |data|
        populate_referral! data
        populate_background_history! data
        populate_diagnosis! data
        populate_functional_status! data
        populate_problem! data
        populate_plan! data
        populate_certification! data
      end
    end

    def populate_referral!(enc_data)
      enc_data.referral ||= Hashie::Mash.new
      enc_data.referral.covering = nil
      enc_data.referral.service_date = now
      enc_data.referral.plan_type ||= Hashie::Mash.new

      if enc_data.referral.plan_type.name == "initial"
        enc_data.referral.plan_type = {
          name: 'followup',
          val: 'a follow up treatment plan'
        }
      end

      if enc_data.referral.order_date.blank?
        enc_data.referral.order_date = now
      end
    end

    def populate_background_history!(enc_data)
      enc_data.background_history ||= Hashie::Mash.new
    end

    def populate_diagnosis!(enc_data)
      enc_data.diagnosis ||= Hashie::Mash.new
      enc_data.diagnosis.medical_conditions =
        enc_data.background_history.medical_conditions
    end

    def populate_functional_status!(enc_data)
      enc_data.functional_status ||= Hashie::Mash.new
    end

    def populate_problem!(enc_data)
      enc_data.problem ||= Hashie::Mash.new

      enc_data.problem.major_target_symptom ||=
        enc_data.referral.medical_necessity || []

      enc_data.problem.onpsychmeds ||= {
        name: "U",
        val: "Unknown"
      }
    end

    def populate_plan!(enc_data)
      enc_data.plan ||= Hashie::Mash.new
    end

    def populate_certification!(enc_data)
      enc_data.certification ||= Hashie::Mash.new
      enc_data.certification.treatment_plan_date = now
    end

  end

end
