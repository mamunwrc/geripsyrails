require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::ReferralValidator, type: :model do
  include_context 'as data validator'

  let(:base_field) { :referral }

  shared_examples 'handles referral :minutes' do #{{{
    describe 'validating' do
      let(:field) { :minutes }
      it_behaves_like 'asserts *number* field'
    end
  end # }}}

  shared_examples 'handles referral :md_name' do # {{{
    describe 'validating' do
      let(:field) { :md_name }
      let(:doc) { pat.facility.doctors.create(name: 'Dr Lah') }
      let(:valid_option) { {name: doc.id, val: doc.name} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles referral :initiator' do # {{{
    describe 'validating' do
      let(:field) { :initiator }
      let(:ref) { create_ref(:REFINITIATOR) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles referral :medical_necessity' do # {{{
    describe 'validating' do
      let(:field) { :medical_necessity }
      let(:ref) { create_ref(:MEDICALNECESSITY) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles referral :plan_type' do # {{{
    describe 'validating' do
      let(:field) { :plan_type }
      let(:ref) { create_ref(:TPTYPE) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles referral :discharge_reason' do # {{{
    describe 'validating (with :plan_type *discharge*)' do
      let(:more_values) { {plan_type: {name: 'discharge'}} }
      let(:field) { :discharge_reason }
      let(:ref) { create_ref(:TPDISREASONS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field'
    end
    describe 'validating (with other :plan_type)' do
      let(:more_values) { {plan_type: {name: 'BLAH'}} }
      let(:field) { :discharge_reason }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles referral :reasons' do # {{{
    describe 'validating' do
      let(:field) { :reasons }
      let(:ref) { create_ref(:REFREASONS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field'
    end
  end # }}}

  shared_examples 'handles referral :hiatus' do # {{{
    describe 'validating' do
      let(:field) { :hiatus }
      let(:valid_option) { {name: 'N', val: 'No'} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles referral :hiatus_reasons' do # {{{
    describe 'validating' do
      let(:more_values) { {hiatus: {name: "Y", value: "Yes"}} }
      let(:field) { :hiatus_reasons }
      let(:ref) { create_ref(:HAS90791THISYEAR) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles referral :hiatus_reason' do # {{{
    describe 'validating (with hiatus)' do
      let(:more_values) { {hiatus: {name: "Y", value: "Yes"}} }
      let(:field) { :hiatus_reason }
      let(:ref) { create_ref(:HAS90791THISYEAR) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
    describe 'validating (without hiatus)' do
      let(:more_values) { {hiatus: {name: "N", value: "No"}} }
      let(:field) { :hiatus_reason }
      it_behaves_like 'not asserting *pick one* field'
    end
  end # }}}

  shared_examples 'handles referral :service_date' do # {{{
    describe 'validating' do
      let(:field) { :service_date }
      it_behaves_like 'asserts *date* field'
    end
  end

  shared_examples 'handles referral :service_date duplication' do # {{{
    let(:field) { :service_date }
    let(:service_date) { 1.day.ago }
    let(:pat2) { create(:patient) }
    let(:values) { {field => service_date} }

    def mk_encounter(date, **extras)
      build(:encounter, {
        patient: pat,
        certify: true,
        certification: { sign_date: date },
        referral: { service_date: date }
      }.merge(extras)).tap do |enc|
        # really hard to set up a proper encounter that passes validation
        enc.save(validate: false)
      end
    end

    context 'without any existing' do
      it { expect(error_msgs).to be_blank }
    end

    context 'with existing but of different dates' do
      let!(:other1) { mk_encounter service_date+1.day }
      let!(:other2) { mk_encounter service_date-1.day }
      it { expect(error_msgs).to be_blank }
    end

    context 'with existing but unsigned conflict' do
      let!(:other) { mk_encounter service_date, certify: false }
      it { expect(error_msgs).to be_blank }
    end

    context 'with existing signed conflict' do
      let!(:other) { mk_encounter service_date }
      it { expect(error_msgs).to include(%('#{error_field}' is duplicated)) }
    end

    context 'with existing signed conflict under another patient' do
      let!(:other) { mk_encounter service_date, patient: pat2 }
      it { expect(error_msgs).to be_blank }
    end
  end # }}}

  shared_examples 'handles referral :order_date' do # {{{
    describe 'validating' do
      let(:field) { :order_date }
      it_behaves_like 'asserts *date* field'
    end
  end # }}}

  shared_examples 'handles referral :hiatus_date' do # {{{
    %w(transferred hospitalized).each do |reason|
      describe "validating (with hiatus & hiatus_reason *#{reason}*)" do
        let(:more_values) { {hiatus: {name: 'Y'}, hiatus_reason: {name: reason}} }
        let(:field) { :hiatus_date }
        it_behaves_like 'asserts *date* field'
      end
      describe "validating (without hiatus but with hiatus_reason *#{reason}*)" do
        let(:more_values) { {hiatus: {name: 'N'}, hiatus_reason: {name: reason}} }
        let(:field) { :hiatus_date }
        it_behaves_like 'not asserting *date* field'
      end
    end
    describe "validating (with other hiatus_reason)" do
      let(:more_values) { {hiatus: {name: 'Y'}, hiatus_reason: {name: 'BLAH'}} }
      let(:field) { :hiatus_date }
      it_behaves_like 'not asserting *date* field'
    end
  end # }}}

  shared_examples 'handles referral :order_date with :service_date' do # {{{
    let(:s_date) { Date.parse("2017-04-18") }
    let(:values) { {service_date: s_date, order_date: o_date} }
    let(:field) { :order_date }

    context 'when :order_date precedes :service_date' do
      let(:o_date) { s_date - 1.day }
      it { expect(error_msgs).to be_blank } 
    end

    context 'when :order_date is same as :service_date' do
      let(:o_date) { s_date }
      it { expect(error_msgs).to be_blank } 
    end

    context 'when :service_date precedes :order_date' do
      let(:o_date) { s_date + 1.day }
      it { expect(error_msgs).to include(%('order_date' must precede 'service_date')) } 
    end
  end # }}}

  describe '907xx' do # {{{
    let(:code) { '907xx' }

    it_behaves_like 'handles referral :md_name'
    it_behaves_like 'handles referral :initiator'
    it_behaves_like 'handles referral :medical_necessity'
    it_behaves_like 'handles referral :reasons'
    it_behaves_like 'handles referral :hiatus'
    it_behaves_like 'handles referral :hiatus_reason'
    it_behaves_like 'handles referral :hiatus_date'
    it_behaves_like 'handles referral :service_date'
    it_behaves_like 'handles referral :order_date'
    it_behaves_like 'handles referral :order_date with :service_date'
    it_behaves_like 'handles referral :service_date duplication'
  end # }}}

  describe '90839' do
    let(:code) { '90839' }

    it_behaves_like 'handles referral :md_name'
    it_behaves_like 'handles referral :initiator'
    it_behaves_like 'handles referral :service_date'
    it_behaves_like 'handles referral :order_date'
    it_behaves_like 'handles referral :service_date duplication'
  end

  describe '908xx' do # {{{
    let(:code) { '908xx' }
    it_behaves_like 'handles referral :service_date'
    it_behaves_like 'handles referral :service_date duplication'
  end # }}}

  describe 'TP' do # {{{
    let(:code) { 'TP' }

    it_behaves_like 'handles referral :service_date'
    it_behaves_like 'handles referral :md_name'
    it_behaves_like 'handles referral :initiator'
    it_behaves_like 'handles referral :order_date'
    it_behaves_like 'handles referral :reasons'
    it_behaves_like 'handles referral :plan_type'
    it_behaves_like 'handles referral :discharge_reason'
  end # }}}

  describe '90853' do # {{{
    let(:code) { '90853' }
    it_behaves_like 'handles referral :service_date'
  end # }}}

  describe '9611x' do # {{{
    let(:code) { '96116' }
    it_behaves_like 'handles referral :minutes'
  end # }}}

end
