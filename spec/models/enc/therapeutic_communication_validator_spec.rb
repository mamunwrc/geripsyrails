require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::TherapeuticCommunicationValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :therapeutic_communication

  describe '908xx' do
    let(:code) { '908xx' }

    describe "with functional_status.interactive_complexity as *Y*" do # {{{
      let(:root_values) { {functional_status: {interactive_complexity: {name: 'Y'} }} }
      has_pick_one_field_without_freetext :service_conducted, :SERVICECONDUCTEDIC
    end # }}}

    describe "with functional_status.interactive_complexity as *N*" do # {{{
      let(:root_values) { {functional_status: {interactive_complexity: {name: 'N'} }} }
      has_pick_one_field_without_freetext :service_conducted, :SERVICECONDUCTEDNOIC
    end # }}}

    describe "with therapeutic_communication.service_conducted as *7*" do # {{{
      let(:more_values) { {service_conducted: {name: '7'}} }
      has_pick_many_field_with_freetext :modalities, :MODALITIES
      has_pick_many_field_without_freetext :therapy_attempted_to, :THERAPYATTEMPT
      has_bool_field :family_present
      has_no_pick_many_field :therapeutic_focus
    end # }}}

    %w(8 9).each do |num|
      describe "with therapeutic_communication.service_conducted as *#{num}*" do # {{{
        let(:more_values) { {service_conducted: {name: num}} }
        has_no_pick_many_field :modalities
        has_no_pick_many_field :therapy_attempted_to
        has_no_bool_field :family_present
        has_pick_many_field_without_freetext :therapeutic_focus, :THERAPYFOCUS
      end # }}}
    end

    describe 'with therapeutic_communication.family_present as *Y*' do # {{{
      let(:more_values) { {family_present: {name: 'Y'}} }
      has_text_field 'family_present.member_name'
      has_text_field 'family_present.member_relationship'
    end # }}}

    describe 'with therapeutic_communication.family_present as *N*' do # {{{
      let(:more_values) { {family_present: {name: 'N'}} }
      has_no_text_field 'family_present.member_name'
      has_no_text_field 'family_present.member_relationship'
    end # }}}

  end
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
