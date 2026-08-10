class Enc::BackgroundHistoryValidator < Enc::DataValidator
  BASE_FIELD = :background_history

protected

  def validate_tp
    check_onpsychmeds
  end

  def validate_908xx
    assert_picked_one :status_changed, :BOOLEAN
    assert_picked_one :meds_changed, :BOOLEAN
    assert_picked_one :condition_changed, :BOOLEAN
  end

  def validate_907xx
    check_hist_mental_ill
    check_onpsychmeds

    assert_picked_one :marital_status, :MARITALSTATUS, freetext: true
    assert_picked_one :family_status, :FAMILYSTATUS, freetext: true
    assert_picked_one :education_status, :EDUSTATUS, freetext: true
    assert_picked_one :occupational_status, :OCCUPATION, freetext: true
    assert_picked_one :birth_place, :BIRTHPLACE, freetext: true
    assert_picked_one :family_background, :FAMILYBACKGRND, freetext: true
    assert_picked_one :raised_by, :RAISEDBY, freetext: true
    assert_picked_one :religious_status, :RELIGIOUSSTATUS, freetext: true
    assert_present :medical_conditions
  end

  def validate_9611x
    # pending...
    true
  end

  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90839, :validate_907xx
  alias_method :validate_90853, :validate_none

  def check_hist_mental_ill
    assert_picked_many :hist_mental_ill, :HISTMETNALILL, freetext: true

    return if (values = enc_data.hist_mental_ill).blank?

    return unless
      values.any?{|h| h[:name] == 'NONE' } && values.size > 1 or
      (values.map{|h| h[:name] } & %w(HISTNOHOSP PSYHOSP)).size > 1

    enc_error(:hist_mental_ill, "has conflicting options")
  end

  def check_onpsychmeds
    assert_picked_one :onpsychmeds, :ONMEDS
  end

end
