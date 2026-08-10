class Enc::ProgressValidator < Enc::DataValidator

  BASE_FIELD = :progress

protected

  alias_method :validate_tp, :validate_none
  alias_method :validate_907xx, :validate_none
  alias_method :validate_90853, :validate_none
  alias_method :validate_90839, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_908xx
    assert_picked_one :session, :SESSIONPROG, freetext: true
    assert_picked_many :monitoring_mechanisms, :MONITORMECH, freetext: true
    assert_present :severity
    assert_present :severity_comments
    assert_picked_one :cgii, :CGII
    assert_picked_one :frequency, :PLANFREQUENCY, freetext: true
    assert_picked_one :duration, :PROGDURATION, freetext: true

    check_family_notes_and_comments
    check_notes
  end

  def validate_9896x
    assert_picked_one :session, :SESSIONPROG, freetext: true
    assert_picked_many :monitoring_mechanisms, :MONITORMECH, freetext: true
    assert_present :severity
    assert_present :severity_comments

    check_family_notes_and_comments
    check_notes
  end

  def check_notes
    unless (sc = enc.therapeutic_communication.try(:service_conducted)).blank?
      return if %w(9 8).include?(sc.name.to_s)
    end

    assert_present :notes
  end

  def check_family_notes_and_comments
    return if (sc = enc.therapeutic_communication.try(:service_conducted)).blank?
    return unless %w(9 8).include?(sc.name.to_s)
    return unless assert_picked_many :family_notes, :FAMTHERAPYATTEMPT

    note_names = enc_data.family_notes.map(&:name).map(&:to_i)
    assert_present :'family_notes_comments.observe' if note_names.include?(1)
    assert_present :'family_notes_comments.assess' if note_names.include?(2)
  end

end
