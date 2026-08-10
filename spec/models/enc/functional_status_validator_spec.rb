require 'rails_helper'
require_relative 'data_validator_shared_examples'

RSpec.describe Enc::FunctionalStatusValidator, type: :model do
  include_context 'as data validator'
  let(:base_field) { :functional_status }

  shared_examples 'handles functional_status :severity' do # {{{
    describe 'validating' do
      let(:field) { :severity }
      let(:ref) { create_ref(:CGIS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :reasoning' do # {{{
    describe 'validating' do
      let(:field) { :reasoning }
      let(:ref) { create_ref(:REASONING) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :alertness' do # {{{
    describe 'validating' do
      let(:field) { :alertness }
      let(:ref) { create_ref(:ALERTNESS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :orientation' do # {{{
    describe 'validating' do
      let(:field) { :orientation }
      let(:ref) { create_ref(:ORIENTATION) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :motivation' do # {{{
    describe 'validating' do
      let(:field) { :motivation }
      let(:ref) { create_ref(:MOTIVATION) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles functional_status :orientation > :problems' do # {{{
    describe 'validating (with *P*)' do
      let(:field) { :'orientation[P].problems' }
      let(:ref) { create_ref(:ORIENTATIONPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *O*)' do
      let(:field) { :'orientation[O].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :appearance' do # {{{
    describe 'validating' do
      let(:field) { :appearance }
      let(:ref) { create_ref(:DRESS) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :appearance > :problems' do # {{{
    describe 'validating (with *P*)' do
      let(:field) { :'appearance[I].problems' }
      let(:ref) { create_ref(:DRESSPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *A*)' do
      let(:field) { :'appearance[A].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :motor' do # {{{
    describe 'validating' do
      let(:field) { :motor }
      let(:ref) { create_ref(:MOTOR) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :motor > :problems' do # {{{
    describe 'validating (with *R*)' do
      let(:field) { :'motor[R].problems' }
      let(:ref) { create_ref(:MOTORPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *N*)' do
      let(:field) { :'motor[N].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :affect' do # {{{
    describe 'validating' do
      let(:field) { :affect }
      let(:ref) { create_ref(:AFFECT) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :affect > :problems' do # {{{
    describe 'validating (with *B*)' do
      let(:field) { :'affect[B].problems' }
      let(:ref) { create_ref(:AFFECTPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *G*)' do
      let(:field) { :'affect[G].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :mood' do # {{{
    describe 'validating' do
      let(:field) { :mood }
      let(:ref) { create_ref(:MOOD) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :mood > :problems' do # {{{
    describe 'validating (with *A*)' do
      let(:field) { :'mood[A].problems' }
      let(:ref) { create_ref(:MOODPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *N*)' do
      let(:field) { :'mood[N].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :attitude' do # {{{
    describe 'validating' do
      let(:field) { :attitude }
      let(:ref) { create_ref(:ATTITUDE) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :attitude > :problems' do # {{{
    describe 'validating (with *B*)' do
      let(:field) { :'attitude[B].problems' }
      let(:ref) { create_ref(:ATTITUDEPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *G*)' do
      let(:field) { :'attitude[G].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :expression' do # {{{
    describe 'validating' do
      let(:field) { :expression }
      let(:ref) { create_ref(:EXPRESSION) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :expression > :problems' do # {{{
    describe 'validating (with *B*)' do
      let(:field) { :'expression[B].problems' }
      let(:ref) { create_ref(:EXPRESSIONPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *G*)' do
      let(:field) { :'expression[G].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :mood' do # {{{
    describe 'validating' do
      let(:field) { :mood }
      let(:ref) { create_ref(:MOOD) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :mood > :problems' do # {{{
    describe 'validating (with *A*)' do
      let(:field) { :'mood[A].problems' }
      let(:ref) { create_ref(:MOODPROB) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *N*)' do
      let(:field) { :'mood[N].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :thought_process' do # {{{
    describe 'validating' do
      let(:field) { :thought_process }
      let(:ref) { create_ref(:THOUGHTPR) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :thought_process > :hallucinations' do # {{{
    describe 'validating (with *3*)' do
      let(:field) { :'thought_process[3].hallucinations' }
      let(:ref) { create_ref(:THOUGHTPRHALL) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *1*)' do
      let(:field) { :'thought_process[1].hallucinations' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :thought_content' do # {{{
    describe 'validating' do
      let(:field) { :thought_content }
      let(:ref) { create_ref(:THOUGHTCONT) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :intellectual_ability' do # {{{
    describe 'validating' do
      let(:field) { :intellectual_ability }
      let(:ref) { create_ref(:INTABILITY) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :insight' do # {{{
    describe 'validating' do
      let(:field) { :insight }
      let(:ref) { create_ref(:INSIGHT) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :recall' do # {{{
    describe 'validating' do
      let(:field) { :recall }
      let(:ref) { create_ref(:RECALL) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :harm' do # {{{
    describe 'validating' do
      let(:field) { :harm }
      let(:valid_option) { {name: 'N', val: 'No'} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :harm > :problems' do # {{{
    describe 'validating (with *Y*)' do
      let(:field) { :'harm[Y].problems' }
      let(:ref) { create_ref(:EXPRHARM) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field'
    end
    describe 'validating (with *N*)' do
      let(:field) { :'harm[N].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :interactive_complexity' do # {{{
    describe 'validating' do
      let(:field) { :interactive_complexity }
      let(:valid_option) { {name: 'N', val: 'No'} }
      it_behaves_like 'asserts *pick one* field'
    end
  end # }}}

  shared_examples 'handles functional_status :interactive_complexity > :problems' do # {{{
    describe 'validating (with *Y*)' do
      let(:field) { :'interactive_complexity[Y].problems' }
      let(:ref) { create_ref(:REASONINTEACTVCOMPLXTY) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick many* field (with FREETEXT)'
    end
    describe 'validating (with *N*)' do
      let(:field) { :'interactive_complexity[N].problems' }
      it_behaves_like 'not asserting *pick many* field'
    end
  end # }}}

  shared_examples 'handles functional_status :respondtreatment' do # {{{
    describe 'validating' do
      let(:field) { :respondtreatment }
      let(:ref) { create_ref(:RESPONDTREATMNT) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles functional_status :respondtreatment_desc' do # {{{
    describe 'validating' do
      let(:field) { :respondtreatment_desc }
      let(:ref) { create_ref(:RESPNDTREATMNTDESC) }
      let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
      it_behaves_like 'asserts *pick one* field (with FREETEXT)'
    end
  end # }}}

  shared_examples 'handles functional_status :cognitive_screen' do # {{{
    describe 'validating' do
      let(:field) { :cognitive_screen }
      it_behaves_like 'asserts *text* field'
    end
  end # }}}

  %w(907xx 90839).each do |enc_code|
    describe enc_code do # {{{
      let(:code) { enc_code }

      it_behaves_like 'handles functional_status :severity'
      it_behaves_like 'handles functional_status :orientation'
      it_behaves_like 'handles functional_status :orientation > :problems'
      it_behaves_like 'handles functional_status :appearance'
      it_behaves_like 'handles functional_status :appearance > :problems'
      it_behaves_like 'handles functional_status :motor'
      it_behaves_like 'handles functional_status :motor > :problems'
      it_behaves_like 'handles functional_status :alertness'
      it_behaves_like 'handles functional_status :mood'
      it_behaves_like 'handles functional_status :mood > :problems'
      it_behaves_like 'handles functional_status :affect'
      it_behaves_like 'handles functional_status :affect > :problems'
      it_behaves_like 'handles functional_status :expression'
      it_behaves_like 'handles functional_status :expression > :problems'
      it_behaves_like 'handles functional_status :attitude'
      it_behaves_like 'handles functional_status :attitude > :problems'
      it_behaves_like 'handles functional_status :reasoning'
      it_behaves_like 'handles functional_status :motivation'
      it_behaves_like 'handles functional_status :thought_process'
      it_behaves_like 'handles functional_status :thought_process > :hallucinations'
      it_behaves_like 'handles functional_status :thought_content'
      it_behaves_like 'handles functional_status :recall'
      it_behaves_like 'handles functional_status :intellectual_ability'
      it_behaves_like 'handles functional_status :insight'
      it_behaves_like 'handles functional_status :harm'
      it_behaves_like 'handles functional_status :harm > :problems'
      it_behaves_like 'handles functional_status :interactive_complexity'
      it_behaves_like 'handles functional_status :interactive_complexity > :problems'
      it_behaves_like 'handles functional_status :respondtreatment'
      it_behaves_like 'handles functional_status :respondtreatment_desc'
      it_behaves_like 'handles functional_status :cognitive_screen'
    end # }}}
  end

  describe '908xx' do # {{{
    let(:code) { '908xx' }

    it_behaves_like 'handles functional_status :severity'
    it_behaves_like 'handles functional_status :attitude'
    it_behaves_like 'handles functional_status :attitude > :problems'
    it_behaves_like 'handles functional_status :harm'
    it_behaves_like 'handles functional_status :harm > :problems'
    it_behaves_like 'handles functional_status :respondtreatment'
    it_behaves_like 'handles functional_status :respondtreatment_desc'
    it_behaves_like 'handles functional_status :cognitive_screen'
    it_behaves_like 'handles functional_status :interactive_complexity'
    it_behaves_like 'handles functional_status :interactive_complexity > :problems'
  end # }}}

  describe 'TP' do # {{{
    let(:code) { 'TP' }

    it_behaves_like 'handles functional_status :severity'
    it_behaves_like 'handles functional_status :respondtreatment'
    it_behaves_like 'handles functional_status :respondtreatment_desc'
    it_behaves_like 'handles functional_status :cognitive_screen'
  end # }}}

end
