require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::ProblemValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :problem

  describe '907xx' do # {{{
    let(:code) { '907xx' }

    has_pick_one_field_with_freetext :onset, :PROBLEMONSET
    has_pick_one_field_with_freetext :frequency, :PROBLEMFREQ
    has_pick_one_field_with_freetext :intensity, :PROBLEMINTENSITY
    has_pick_one_field_with_freetext :staffimpression, :STAFFIMPRESSION

    has_pick_many_field_with_freetext :other, :PROBLEMSOTHER
    has_pick_many_field_with_freetext :precipstressors, :PRECIPSTRESSORS

    has_text_field :observation
  end # }}}

  describe '90839' do # {{{
    let(:code) { '90839' }

    has_pick_many_field_with_freetext :crisis_state, :CRISISSTATES
    has_pick_one_field_with_freetext :intensity, :PROBLEMINTENSITY
    has_pick_one_field_without_freetext :crisis_history, :CRISISHIST
    has_pick_many_field_with_freetext :crisis_distress, :CRISISDISTRESS
  end # }}}

  describe '908xx' do # {{{
    let(:code) { '908xx' }

    has_pick_one_field_with_freetext :onset, :PROBLEMONSET
    has_pick_one_field_with_freetext :frequency, :PROBLEMFREQ
    has_pick_one_field_with_freetext :intensity, :PROBLEMINTENSITY

    has_pick_many_field_with_freetext :major_target_symptom, :MAJORTARGETSYM
    has_pick_many_field_with_freetext :other, :PROBLEMSOTHER
  end # }}}

  describe 'TP' do # {{{
    let(:code) { 'TP' }

    has_pick_many_field_with_freetext :major_target_symptom, :MAJORTARGETSYM
    has_pick_one_field_with_freetext :onset, :PROBLEMONSET
    has_pick_one_field_with_freetext :frequency, :PROBLEMFREQ
    has_pick_one_field_with_freetext :intensity, :PROBLEMINTENSITY
    has_pick_many_field_with_freetext :other, :PROBLEMSOTHER
    has_pick_many_field_with_freetext :tp_interventions, :TPINTERVENTIONS
  end # }}}

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
