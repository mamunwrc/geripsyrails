require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::TpMethodsValidator, type: :model do
  include_context 'as data validator'
  include_validation_macros :tp_methods

  def lookup_val(name)
    enc_lookup('TPMETHODS', name)['value']
  end

  def self.has_current_and_target(meth_name) # {{{
    describe "handles tp_methods :methods with *#{meth_name}*" do
      describe 'when selected' do
        let(:more_values) { {methods: [{name: meth.keyname, val: meth.keyvalue}]} }
        let(:meth) { create_ref(:TPMETHODS, meth_name, lookup_val(meth_name)) }

        describe "validating *#{meth_name}*" do
          let(:field) { meth_name }
          it_behaves_like 'asserts *hash-like* field'
        end
        describe "validating *#{meth_name}.current*" do
          let(:field) { :"#{meth_name}.current" }
          it_behaves_like 'asserts *text* field'
        end
        describe "validating *#{meth_name}.target*" do
          let(:field) { :"#{meth_name}.target" }
          it_behaves_like 'asserts *text* field'
        end
      end
      describe 'when not selected' do
        describe "validating *#{meth_name}*" do
          let(:field) { meth_name }
          it_behaves_like 'not asserting *hash-like* field'
        end
        describe "validating *#{meth_name}.current*" do
          let(:field) { :"#{meth_name}.current" }
          it_behaves_like 'not asserting *text* field'
        end
        describe "validating *#{meth_name}.target*" do
          let(:field) { :"#{meth_name}.target" }
          it_behaves_like 'not asserting *text* field'
        end
      end
    end
  end # }}}

  describe 'TP' do
    let(:code) { 'TP' }

    describe 'handles tp_methods :methods' do # {{{
      let(:field) { :methods }
      let(:ref) { create_ref(:TPMETHODS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field'
    end # }}}

    has_current_and_target 'gai'
    has_current_and_target 'gaisf'
    has_current_and_target 'csd'
    has_current_and_target 'staff'
    has_current_and_target 'discharge'
    has_current_and_target 'diffscale'
  end

end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
