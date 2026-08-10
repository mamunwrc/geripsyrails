require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::CompetencyValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :competency

  describe '907xx' do # {{{
    let(:code) { '907xx' }

    describe 'with referral.reasons including *2*' do
      let(:root_values) { {referral: {reasons: [{name: '2'}]}} }
      has_pick_one_field_with_freetext :findings, :COMPETENCYFINDINGS
    end

    describe 'with referral.reasons not including *2*' do
      let(:root_values) { {referral: {reasons: [{name: '1'}]}} }
      has_no_pick_one_field :findings
    end

  end # }}}

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
