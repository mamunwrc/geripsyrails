require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::GroupDataValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :group_data

  let(:practice) { patient.facility.practice }
  let(:patient) { create(:patient) }
  let(:group_session) { OpenStruct.new(id: 99889988) }
  let(:group) { create(:group, practice_id: practice.id) }
  let(:root_values) { {patient_id: patient.id, group_session: group_session} }

  shared_examples 'handles group_data :group_id' do # {{{
    describe 'validating' do
      let(:field) { :group_id }
      let(:valid_id) { group.id }
      it_behaves_like 'asserts *relation* field'
    end
  end # }}}

  shared_examples 'handles group_data :session_id' do # {{{
    describe 'validating' do
      let(:field) { :session_id }
      let(:valid_id) { group_session.id }
      it_behaves_like 'asserts *relation* field'
    end
  end # }}}

  shared_examples 'handles group_data :interventions' do # {{{
    has_text_field :'interventions.dynamics'
    has_text_field :'interventions.description'
    has_pick_many_field_without_freetext :'interventions.therapeutic_factors', :THERAPEUTICFACTORS
    has_pick_one_field_without_freetext :'interventions.cgii', :CGII
  end # }}}

  shared_examples 'handles group_data :session' do # {{{
    has_text_field :'session.theme'
    has_text_field :'session.goal'
    has_text_field :'session.description'

    describe 'handles group_data :session.participants' do
      let(:field) { :'session.participants' }

      context 'when more than 1' do
        let(:values) { {field => 2} }
        it { expect(error_msgs).to be_blank }
      end

      context 'when less than 1' do
        let(:values) { {field => 1} }
        it { expect(error_msgs).to include(%('#{error_field}' must be more than 1)) }
      end
    end
  end # }}}

  describe '90853' do
    let(:code) { '90853' }

    it_behaves_like 'handles group_data :group_id'
    it_behaves_like 'handles group_data :session_id'
    it_behaves_like 'handles group_data :interventions'
    it_behaves_like 'handles group_data :session'
  end 

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
