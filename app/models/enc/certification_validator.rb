class Enc::CertificationValidator < Enc::DataValidator

  BASE_FIELD = :certification

protected

  def validate_907xx
    assert_time :start_time
    assert_time :end_time
  end

  alias_method :validate_90839, :validate_907xx
  alias_method :validate_908xx, :validate_907xx
  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90853, :validate_907xx
  alias_method :validate_tp, :validate_none
  alias_method :validate_9611x, :validate_none

end
