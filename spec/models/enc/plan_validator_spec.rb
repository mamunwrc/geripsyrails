require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::PlanValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :plan

  shared_examples 'handles plan :amount_of_service & :not_recommended_reason' do # {{{
    describe 'validating (with *4*)' do
      let(:field) { :not_recommended_reason }
      let(:ref1) { create_ref(:PLANRECOMMENDED, '4', 'Not recommended') }
      let(:ref2) { create_ref(:PLANNOTRECOMMENDED) }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      let(:valid_option) { {name: ref2.keyname, val: ref2.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (without *4*)' do
      let(:field) { :not_recommended_reason }
      let(:ref1) { create_ref(:PLANRECOMMENDED, 'foo', 'bar') }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles plan :amount_of_service & :frequency' do # {{{
    describe 'validating (with *4*)' do
      let(:field) { :frequency }
      let(:ref1) { create_ref(:PLANRECOMMENDED, '4', 'Not recommended') }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'not asserting *pick one* field'
    end
    describe 'validating (without *4*)' do
      let(:field) { :frequency }
      let(:ref1) { create_ref(:PLANRECOMMENDED, 'foo', 'bar') }
      let(:ref2) { create_ref(:PLANFREQUENCY) }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      let(:valid_option) { {name: ref2.keyname, val: ref2.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles plan :amount_of_service & :duration' do # {{{
    describe 'validating (with *4*)' do
      let(:field) { :duration }
      let(:ref1) { create_ref(:PLANRECOMMENDED, '4', 'Not recommended') }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'not asserting *pick one* field'
    end
    describe 'validating (without *4*)' do
      let(:field) { :duration }
      let(:ref1) { create_ref(:PLANRECOMMENDED, 'foo', 'bar') }
      let(:ref2) { create_ref(:PLANDURATION) }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      let(:valid_option) { {name: ref2.keyname, val: ref2.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles plan :amount_of_service & :other_services' do # {{{
    describe 'validating (with *4*)' do
      let(:field) { :other_services }
      let(:ref1) { create_ref(:PLANRECOMMENDED, '4', 'Not recommended') }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'not asserting *pick many* field'
    end
    describe 'validating (without *4*)' do
      let(:field) { :other_services }
      let(:ref1) { create_ref(:PLANRECOMMENDED, 'foo', 'bar') }
      let(:ref2) { create_ref(:PLANOTHERSERVICES) }
      let(:more_values) { {amount_of_service: {name: ref1.keyname, val: ref1.keyvalue}} }
      let(:valid_option) { {name: ref2.keyname, val: ref2.keyvalue} }
      it_behaves_like 'asserts *pick many* field (OPTIONAL with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles plan :crisis_additional_time & :crisis_additional_time_minutes' do # {{{
    describe 'validating (with *Y*)' do
      let(:field) { :crisis_additional_time_minutes }
      let(:ref) { create_ref(:CRISISTIME) }
      let(:more_values) { {crisis_additional_time: {name: 'Y', val: 'Yes'}} }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
    describe 'validating (with *N*)' do
      let(:field) { :crisis_additional_time_minutes }
      let(:more_values) { {crisis_additional_time: {name: 'N', val: 'No'}} }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles plan :crisis_recommendations & :crisis_recommendation_until' do # {{{
    describe 'validating (with *1*)' do
      let(:field) { :crisis_recommendation_until }
      let(:ref1) { create_ref(:CRISISRECS, '1', '1:1 staff coverage until:') }
      let(:more_values) { {crisis_recommendations: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'asserts *text* field'
    end
    describe 'validating (without *1*)' do
      let(:field) { :crisis_recommendation_until }
      let(:ref1) { create_ref(:CRISISRECS, 'foo', 'bar') }
      let(:more_values) { {crisis_recommendations: {name: ref1.keyname, val: ref1.keyvalue}} }
      it_behaves_like 'not asserting *text* field'
    end
  end # }}}

  %w(907xx TP).each do |enc_code|
    describe enc_code do # {{{
      let(:code) { enc_code }

      context 'with ref.reasons including *1*' do
        let(:root_values) { {referral: {reasons: [{name: '1'}]} } }
        has_pick_one_field_without_freetext :amount_of_service, :PLANRECOMMENDED

        it_behaves_like 'handles plan :amount_of_service & :not_recommended_reason'
        it_behaves_like 'handles plan :amount_of_service & :frequency'
        it_behaves_like 'handles plan :amount_of_service & :duration'
        it_behaves_like 'handles plan :amount_of_service & :other_services'
      end

      context 'with ref.reasons not including *1*' do
        let(:root_values) { {referral: {reasons: [{name: '2'}]} } }
        has_no_pick_one_field :amount_of_service
      end
    end # }}}
  end

  describe '90839' do # {{{
    let(:code) { '90839' }

    has_pick_one_field_without_freetext :crisis_psychotherapy, :CRISISPSYCH
    has_pick_many_field_with_freetext :crisis_mobilization, :CRISISMOBILIZATION
    has_text_field :crisis_intervention_summary
    has_pick_one_field_without_freetext :crisis_risk_assessment, :CRISISRISK

    has_pick_one_field_without_freetext :crisis_recommendations, :CRISISRECS
    it_behaves_like 'handles plan :crisis_recommendations & :crisis_recommendation_until'

    has_bool_field :crisis_additional_time
    it_behaves_like 'handles plan :crisis_additional_time & :crisis_additional_time_minutes'
  end # }}}

  describe '908xx' do # {{{
    let(:code) { '908xx' }
    # noop
  end # }}}

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
