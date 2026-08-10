class Enc::GroupDataValidator < Enc::DataValidator

  BASE_FIELD = :group_data

protected

  def validate_90853
    check_group_id
    check_session_id
    check_interventions
    check_session
  end

  alias_method :validate_90839, :validate_none
  alias_method :validate_908xx, :validate_none
  alias_method :validate_9896x, :validate_908xx
  alias_method :validate_907xx, :validate_none
  alias_method :validate_tp, :validate_none
  alias_method :validate_9611x, :validate_none

private

  def check_session
    return unless assert_present :session
    assert_present :'session.theme'
    assert_present :'session.goal'
    assert_present :'session.description'

    unless enc_data(f = :'session.participants').to_i > 1
      enc_error(f, "must be more than 1")
    end
  end

  def check_interventions
    return unless assert_present :interventions
    assert_present :'interventions.dynamics'
    assert_present :'interventions.description'
    assert_picked_many :'interventions.therapeutic_factors', :THERAPEUTICFACTORS
    assert_picked_one :'interventions.cgii', :CGII
  end

  def check_group_id
    assert_relation :group_id, lambda{|group_id|
      not Grp::Group.where({
        practice_id: enc.patient.practice_id,
        id: group_id,
      }).empty?
    }
  end

  def check_session_id
    assert_relation :session_id, lambda{|session_id|
      session_id == enc.group_session.try(:id)
    }
  end

end
