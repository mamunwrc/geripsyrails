class Enc::PlanValidator < Enc::DataValidator

  BASE_FIELD = :plan

protected

  alias_method :validate_908xx, :validate_none
  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90853, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_tp
    check_amount_of_service_and_related
  end

  def validate_907xx
    check_amount_of_service_and_related
  end

  def validate_90839
    assert_picked_one :crisis_psychotherapy, :CRISISPSYCH
    assert_picked_many :crisis_mobilization, :CRISISMOBILIZATION, freetext: true
    assert_present :crisis_intervention_summary
    assert_picked_one :crisis_risk_assessment, :CRISISRISK

    check_crisis_recommendations_and_related
    check_crisis_additional_time_and_minutes
  end

  def check_amount_of_service_and_related
    ref_reasons = (enc.referral.try(:reasons) || []).map(&:name).map(&:to_s)
    return unless '1'.in?(ref_reasons)
    return unless assert_picked_one :amount_of_service, :PLANRECOMMENDED

    if enc_data.amount_of_service.try(:name) == '4'
      assert_picked_many :not_recommended_reason, :PLANNOTRECOMMENDED, freetext: true
    else
      assert_picked_one :frequency, :PLANFREQUENCY, freetext: true 
      assert_picked_one :duration, :PLANDURATION, freetext: true 
      assert_picked_many :other_services, :PLANOTHERSERVICES, freetext: true, optional: true
    end
  end

  def check_crisis_recommendations_and_related
    return unless assert_picked_one :crisis_recommendations, :CRISISRECS
    return unless enc_data.crisis_recommendations.try(:name) == '1'
    assert_present :crisis_recommendation_until
  end

  def check_crisis_additional_time_and_minutes
    return unless assert_picked_one :crisis_additional_time, :BOOLEAN
    return unless enc_data.crisis_additional_time.try(:name) == 'Y'
    assert_picked_one :crisis_additional_time_minutes, :CRISISTIME
  end

end
