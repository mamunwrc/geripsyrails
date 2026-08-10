require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::ProgressValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :progress

  def lookup_val(num)
    enc_lookup('FAMTHERAPYATTEMPT', num)['value']
  end

  def self.has_interaction_therapeutic_communication(num) # {{{
    describe "having interaction with therapeutic_communication *#{num}*" do # {{{
      let(:root_values) { {therapeutic_communication: {service_conducted: {name: num.to_s}} } }
      has_pick_many_field_without_freetext :family_notes, :FAMTHERAPYATTEMPT

      describe 'validating :family_notes_comments' do
        let(:ref) { create_ref(:FAMTHERAPYATTEMPT, ref_key, lookup_val(ref_key)) }
        let(:more_values) { {family_notes: [{name: ref.keyname, val: ref.keyvalue}]} }

        describe 'with :family_notes *1*' do
          let(:ref_key) { '1' }
          has_text_field 'family_notes_comments.observe'
        end

        describe 'validating :family_notes_comments (with :family_notes *2*)' do
          let(:ref_key) { '2' }
          has_text_field 'family_notes_comments.assess'
        end
      end

      describe 'validating :notes' do
        let(:field) { 'notes' }
        it_behaves_like 'not asserting *text* field'
      end
    end # }}}
  end # }}}

  def self.has_no_interaction_therapeutic_communication(num) # {{{
    describe "having interaction with therapeutic_communication *#{num}*" do # {{{
      let(:root_values) { {therapeutic_communication: {service_conducted: {name: num.to_s}} } }
      has_no_pick_many_field :family_notes
      has_text_field :notes
    end # }}}
  end # }}}

  describe '908xx' do 
    let(:code) { '908xx' }

    has_pick_one_field_with_freetext :session, :SESSIONPROG
    has_pick_many_field_with_freetext :monitoring_mechanisms, :MONITORMECH
    has_text_field :severity
    has_text_field :severity_comments
    has_pick_one_field_without_freetext :cgii, :CGII
    has_pick_one_field_with_freetext :frequency, :PLANFREQUENCY
    has_pick_one_field_with_freetext :duration, :PROGDURATION

    has_interaction_therapeutic_communication 9
    has_interaction_therapeutic_communication 8

    has_no_interaction_therapeutic_communication 7
  end

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
