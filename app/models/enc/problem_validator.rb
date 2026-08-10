class Enc::ProblemValidator < Enc::DataValidator

  BASE_FIELD = :problem

protected

  alias_method :validate_90853, :validate_none
  alias_method :validate_9611x, :validate_none

  def validate_tp
    check_major_target_symptom
    check_onset_frequency_intensity_other

    if enc.cpt_encounter_code == 'GBH1'
      assert_picked_many :tp_interventions, :GBH1INTERVENTIONS, freetext: true
    else
      assert_picked_many :tp_interventions, :TPINTERVENTIONS, freetext: true
    end
    assert_picked_one :onpsychmeds, :ONMEDS
  end

  def validate_908xx
    check_major_target_symptom
    check_onset_frequency_intensity_other
  end

  alias_method :validate_9896x, :validate_908xx

  def validate_90839
    check_intensity

    assert_picked_many :crisis_state, :CRISISSTATES, freetext: true
    assert_picked_one :crisis_history, :CRISISHIST
    assert_picked_many :crisis_distress, :CRISISDISTRESS, freetext: true
  end

  def validate_907xx
    check_onset_frequency_intensity_other

    assert_picked_one :staffimpression, :STAFFIMPRESSION, freetext: true
    assert_picked_many :precipstressors, :PRECIPSTRESSORS, freetext: true
    assert_present :observation
  end

  def check_onset_frequency_intensity_other
    check_intensity

    assert_picked_one :onset, :PROBLEMONSET, freetext: true
    assert_picked_one :frequency, :PROBLEMFREQ, freetext: true
    assert_picked_many :other, :PROBLEMSOTHER, freetext: true
  end

  def check_intensity
    assert_picked_one :intensity, :PROBLEMINTENSITY, freetext: true
  end

  def check_major_target_symptom
    assert_picked_many :major_target_symptom, :MAJORTARGETSYM, freetext: true
  end
end
