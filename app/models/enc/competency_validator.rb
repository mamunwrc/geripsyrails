class Enc::CompetencyValidator < Enc::DataValidator

  BASE_FIELD = :competency

protected

  alias_method :validate_tp, :validate_none
  alias_method :validate_90853, :validate_none
  alias_method :validate_908xx, :validate_none
  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90839, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_907xx
    ref_reasons = (enc.referral.try(:reasons) || []).map(&:name).map(&:to_s)
    return unless ref_reasons.include?('2')
    assert_picked_one :findings, :COMPETENCYFINDINGS, freetext: true
  end

end
