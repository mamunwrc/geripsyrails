class Enc::ReferralValidator < Enc::DataValidator

  BASE_FIELD = :referral

protected

  def validate_9611x
    assert_present :minutes
    assert_number :minutes
  end

  def validate_90853
    check_service_date
    check_service_date_doesnt_duplicate
    check_service_precedes_signed_on
  end

  def validate_tp
    check_initiator_and_md_name
    check_initiator_md_name_and_reasons
    check_service_and_order_date
    check_service_precedes_signed_on

    check_plan_type_and_discharge_reason
  end

  def validate_908xx
    check_service_date
    check_service_date_doesnt_duplicate
    check_service_precedes_signed_on
  end

  alias_method :validate_9896x, :validate_908xx

  def validate_907xx
    check_initiator_md_name_and_reasons
    check_service_and_order_date
    check_service_precedes_order_date
    check_service_date_doesnt_duplicate
    check_service_precedes_signed_on

    check_hiatus_and_related

    assert_picked_many :medical_necessity, :MEDICALNECESSITY, freetext: true
  end

  def validate_90839
    check_initiator_and_md_name
    check_service_and_order_date
    check_service_date_doesnt_duplicate
    check_service_precedes_signed_on
  end

  def check_service_and_order_date(**opts)
    check_service_date
    check_order_date
  end

  def check_service_date_doesnt_duplicate
    begin
      date = Date.parse(enc_data.service_date.to_s)
      base_query = enc.patient.encounters.signed
      cpt = enc.encounter_type

      date_checker = Enc::ServiceDateDupCheck.run(enc.patient_id, cpt, date, enc.id)

      return if date_checker.ok?

      enc_error :service_date, 'is duplicated'
    rescue ArgumentError
      # ignoring
    end
  end

  def check_service_precedes_order_date
    begin
      return unless o_date = enc_data.order_date.try(:to_datetime)
      return unless s_date = enc_data.service_date.try(:to_datetime)

      if o_date.beginning_of_day > s_date.beginning_of_day
        enc_error(:order_date, "must precede 'service_date'")
      end
    rescue ArgumentError
      # ignoring
    end
  end

  def check_service_precedes_signed_on
    begin
      return unless signed_on = enc.signed_on.try(:to_datetime)
      return unless service_date = enc_data.service_date.try(:to_datetime)

      if signed_on.beginning_of_day < service_date.beginning_of_day
        enc_error(:signed_on, "must precede 'service_date'")
      end
    rescue ArgumentError
      # ignoring
    end
  end

  def check_service_date
    assert_date :service_date
  end

  def check_order_date
    assert_date :order_date
  end

  def check_hiatus_and_related
    assert_picked_one :hiatus, :BOOLEAN

    return unless enc_data.hiatus.try(:name) == 'Y'
    assert_picked_one :hiatus_reason, :HAS90791THISYEAR, freetext: true

    return unless %w(transferred hospitalized).include? enc_data.hiatus_reason.try(:name)
    assert_date :hiatus_date
  end

  def check_initiator_and_md_name
    assert_picked_many :initiator, :REFINITIATOR, freetext: true

    choices = lambda { Hash[enc.patient.facility.doctors.pluck(:id, :name)] }
    assert_picked_one :md_name, choices, freetext: true
  end
  
  def check_initiator_md_name_and_reasons
    check_initiator_and_md_name
    assert_picked_many :reasons, :REFREASONS
  end

  def check_plan_type_and_discharge_reason
    if enc.cpt_encounter_code == 'GBH1'
      assert_picked_one :plan_type, :GBH1TYPE
    else
      assert_picked_one :plan_type, :TPTYPE
    end
    return unless enc_data.plan_type.try(:name) == 'discharge'
    assert_picked_many :discharge_reason, :TPDISREASONS, freetext: true
  end

end
