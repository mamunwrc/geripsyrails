class Enc::DiagnosisValidator < Enc::DataValidator

  BASE_FIELD = :diagnosis

protected

  def validate_tp
    check_primary_seconday_prognosis
    assert_present :medical_conditions
  end

  def validate_908xx
    check_primary_seconday_prognosis
    assert_present :general_goals
    assert_present :session_goals
  end

  def validate_907xx
    check_primary_seconday_prognosis
  end

  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90839, :validate_907xx
  alias_method :validate_90853, :validate_none
  alias_method :validate_9611x, :validate_none

  def check_primary_seconday_prognosis
    assert_picked_one :primary, :ICDREFS
    assert_picked_one :secondary, :ICDREFS, optional: true
    assert_picked_one :prognosis, :PROGNOSIS
  end

end
