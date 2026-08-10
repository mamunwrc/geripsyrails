require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::BackgroundHistoryValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :background_history

  shared_examples 'handles background_history :hist_mental_ill' do # {{{
    let!(:refs) do
      OpenStruct.new(Hash[
        [%w(NONE a), %w(U b), %w(PSYHOSP c), %w(HISTNOHOSP d)].map{|name, val|
          create_ref(:HISTMETNALILL, name, val)
          [name, val]
        }
      ])
    end

    let(:field) { :hist_mental_ill }

    describe 'validating' do
      let(:valid_option) { {name: 'U', val: refs.U} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end

    describe 'validating (with *NONE*)' do
      let(:values) { {field => [{name: 'NONE', val: refs.NONE}, {name: 'U', val: refs.U}]} }
      it { expect(error_msgs).to include(%('#{error_field}' has conflicting options)) }
    end

    describe 'validating (with *PSYHOSP*)' do
      let(:option1) { {name: 'PSYHOSP', val: refs.PSYHOSP} }
      let(:values) { {field => [option1, option2]} }

      context 'without *HISTNOHOSP*' do
        let(:option2) { {name: 'U', val: refs.U} }
        it { expect(error_msgs).to be_blank }
      end
      context 'with *HISTNOHOSP*' do
        let(:option2) { {name: 'HISTNOHOSP', val: refs.HISTNOHOSP} }
        it { expect(error_msgs).to include(%('#{error_field}' has conflicting options)) }
      end
    end
  end # }}}

  shared_examples 'handles background_history :onpsychmeds_medication' do # {{{
    describe 'validating (with onpsychmeds: Y)' do
      let(:field) { :onpsychmeds_medication }
      let(:more_values) { {onpsychmeds: {name: 'Y', val: 'Yes'}} }
      it_behaves_like 'asserts *text* field'
    end
    describe 'validating (with onpsychmeds: N)' do
      let(:field) { :onpsychmeds_medication }
      let(:more_values) { {onpsychmeds: {name: 'N', val: 'No'}} }
      it_behaves_like 'not asserting *text* field'
    end
  end # }}}

  %w(907xx 90839).each do |enc_code|
    describe enc_code do # {{{
      let(:code) { enc_code }

      has_pick_one_field_with_freetext :marital_status, :MARITALSTATUS
      has_pick_one_field_with_freetext :family_status, :FAMILYSTATUS
      has_pick_one_field_with_freetext :education_status, :EDUSTATUS
      has_pick_one_field_with_freetext :occupational_status, :OCCUPATION
      has_pick_one_field_with_freetext :birth_place, :BIRTHPLACE
      has_pick_one_field_with_freetext :family_background, :FAMILYBACKGRND
      has_pick_one_field_with_freetext :raised_by, :RAISEDBY
      has_pick_one_field_with_freetext :religious_status, :RELIGIOUSSTATUS
      has_pick_one_field_without_freetext :onpsychmeds, :ONMEDS
      has_text_field :medical_conditions

      it_behaves_like 'handles background_history :hist_mental_ill'

      # QUESTION: is *onpsychmeds_medication* required ??
      #it_behaves_like 'handles background_history :onpsychmeds_medication'
    end # }}}
  end

  describe '908xx' do # {{{
    let(:code) { '908xx' }

    has_bool_field :status_changed
    has_bool_field :meds_changed
    has_bool_field :condition_changed
  end # }}}

  describe 'TP' do # {{{
    let(:code) { 'TP' }

    has_pick_one_field_without_freetext :onpsychmeds, :ONMEDS

    # QUESTION: is *onpsychmeds_medication* required ??
    #it_behaves_like 'handles background_history :onpsychmeds_medication'
  end # }}}

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
