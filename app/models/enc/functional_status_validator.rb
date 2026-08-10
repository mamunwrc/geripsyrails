class Enc::FunctionalStatusValidator < Enc::DataValidator
  BASE_FIELD = :functional_status

protected

  def validate_tp
    check_severity
    check_respondtreatment_and_related
  end

  def validate_9611x
    # TODO...
    true
  end

  def validate_908xx
    check_severity
    check_attitude_and_problems
    check_respondtreatment_and_related
    check_harm_and_problems
    check_interactive_complexity_and_problems
  end

  def validate_907xx
    check_severity
    check_attitude_and_problems
    check_harm_and_problems
    check_respondtreatment_and_related
    check_interactive_complexity_and_problems

    check_orientation_and_problems
    check_appearance_and_problems
    check_motor_and_problems
    check_mood_and_problems
    check_affect_and_problems
    check_expression_and_problems
    check_thought_process_and_hallucinations

    assert_picked_one :alertness, :ALERTNESS
    assert_picked_one :reasoning, :REASONING
    assert_picked_one :motivation, :MOTIVATION, freetext: true
    assert_picked_one :insight, :INSIGHT
    assert_picked_one :recall, :RECALL
    assert_picked_one :intellectual_ability, :INTABILITY
    assert_picked_one :thought_content, :THOUGHTCONT
  end

  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_90839, :validate_907xx
  alias_method :validate_90853, :validate_none

  def check_severity
    assert_picked_one :severity, :CGIS
  end
  
  def check_orientation_and_problems
    assert_picked_one :orientation, :ORIENTATION
    return unless enc_data.orientation.try(:name) == 'P'
    assert_picked_many 'orientation.problems', :ORIENTATIONPROB, freetext: true
  end

  def check_appearance_and_problems
    assert_picked_one :appearance, :DRESS
    return unless enc_data.appearance.try(:name) == 'I'
    assert_picked_many 'appearance.problems', :DRESSPROB, freetext: true
  end

  def check_motor_and_problems
    assert_picked_one :motor, :MOTOR
    return unless enc_data.motor.try(:name) == 'R'
    assert_picked_many 'motor.problems', :MOTORPROB, freetext: true
  end

  def check_mood_and_problems
    assert_picked_one :mood, :MOOD
    return unless enc_data.mood.try(:name) == 'A'
    assert_picked_many 'mood.problems', :MOODPROB, freetext: true
  end

  def check_affect_and_problems
    assert_picked_one :affect, :AFFECT
    return unless enc_data.affect.try(:name) == 'B'
    assert_picked_many 'affect.problems', :AFFECTPROB, freetext: true
  end

  def check_expression_and_problems
    assert_picked_one :expression, :EXPRESSION
    return unless enc_data.expression.try(:name) == 'B'
    assert_picked_many 'expression.problems', :EXPRESSIONPROB, freetext: true
  end

  def check_attitude_and_problems
    assert_picked_one :attitude, :ATTITUDE
    return unless enc_data.attitude.try(:name) == 'B'
    assert_picked_many 'attitude.problems', :ATTITUDEPROB, freetext: true
  end

  def check_thought_process_and_hallucinations
    assert_picked_one :thought_process, :THOUGHTPR
    return unless enc_data.thought_process.try(:name).to_i == 3
    assert_picked_many 'thought_process.hallucinations', :THOUGHTPRHALL, freetext: true
  end

  def check_harm_and_problems
    assert_picked_one :harm, :BOOLEAN
    return unless enc_data.harm.try(:name) == 'Y'
    assert_picked_many 'harm.problems', :EXPRHARM
  end

  def check_attitude
    assert_picked_one :attitude, :ATTITUDE
    return unless enc_data.attitude.try(:name) == 'B'
    assert_picked_many 'attitude.problems', :ATTITUDEPROB, freetext: true
  end

  def check_interactive_complexity_and_problems
    assert_picked_one :interactive_complexity, :BOOLEAN
    return unless enc_data.interactive_complexity.try(:name) == 'Y'
    assert_picked_many 'interactive_complexity.problems', :REASONINTEACTVCOMPLXTY, freetext: true
  end

  def check_respondtreatment_and_related
    assert_picked_one :respondtreatment, :RESPONDTREATMNT, freetext: true
    assert_present :cognitive_screen
    assert_picked_one :respondtreatment_desc, :RESPNDTREATMNTDESC, freetext: true
  end

end
