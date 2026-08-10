require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::DiagnosisValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :diagnosis

  def create_icd
    Ref::Icd.create(group: 1, description: "HeLLo", icd: "F-99")
  end

  def self.has_pick_one_icd_without_freetext(field_name, **opts) # {{{
    describe "handles diagnosis :#{field_name}" do
      let(:field) { field_name }
      let(:icd) { create_icd }
      let(:valid_option) { {name: icd.icd, val: [icd.icd,icd.description]*' - '} }

      it_behaves_like opts[:optional] ?
        'asserts *pick one* field (OPTIONAL)' : 'asserts *pick one* field'
    end
  end # }}}

  %w(907xx 90839).each do |enc_code|
    describe enc_code do # {{{
      let(:code) { enc_code }

      has_pick_one_icd_without_freetext :primary
      has_pick_one_icd_without_freetext :secondary, optional: true
      has_pick_one_field_without_freetext :prognosis, :PROGNOSIS
    end # }}}
  end

  describe '908xx' do # {{{
    let(:code) { '908xx' }

    has_pick_one_icd_without_freetext :primary
    has_pick_one_icd_without_freetext :secondary, optional: true
    has_text_field :general_goals
    has_text_field :session_goals
    has_pick_one_field_without_freetext :prognosis, :PROGNOSIS
  end # }}}

  describe 'TP' do # {{{
    let(:code) { 'TP' }

    has_pick_one_icd_without_freetext :primary
    has_pick_one_icd_without_freetext :secondary, optional: true
    has_pick_one_field_without_freetext :prognosis, :PROGNOSIS
    has_text_field :medical_conditions
  end # }}}

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
