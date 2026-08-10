class Enc::TherapeuticCommunicationValidator < Enc::DataValidator

  BASE_FIELD = :therapeutic_communication

protected

  alias_method :validate_tp, :validate_none
  alias_method :validate_90853, :validate_none
  alias_method :validate_907xx, :validate_none
  alias_method :validate_90839, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_908xx
    service_cond = enc_data.service_conducted.try(:name).to_i

    if [8,9].include?(service_cond)
      assert_picked_many :therapeutic_focus, :THERAPYFOCUS
    elsif !service_cond.zero?
      assert_picked_many :modalities, :MODALITIES, freetext: true
      assert_picked_many :therapy_attempted_to, :THERAPYATTEMPT
      assert_picked_one :family_present, :BOOLEAN
    end

    check_service_conducted
    check_family_present_member
  end

  def validate_9896x
    service_cond = enc_data.service_conducted.try(:name).to_i

    if !service_cond.zero?
      assert_picked_many :modalities, :MODALITIES, freetext: true
      assert_picked_many :therapy_attempted_to, :THERAPYATTEMPT
      assert_picked_one :family_present, :BOOLEAN
    end

    assert_picked_one :service_conducted, :SERVICECONDUCTEDTELEMED
    check_family_present_member
  end

  def check_family_present_member
    return unless enc_data.family_present.try(:name) == 'Y'
    assert_present 'family_present.member_name'
    assert_present 'family_present.member_relationship'
  end

  def check_service_conducted
    case enc.functional_status.try(:interactive_complexity).try(:name)
    when 'Y'
      assert_picked_one :service_conducted, :SERVICECONDUCTEDIC
    when 'N'
      assert_picked_one :service_conducted, :SERVICECONDUCTEDNOIC
    end
  end

end
