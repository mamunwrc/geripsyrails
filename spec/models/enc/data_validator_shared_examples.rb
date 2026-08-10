shared_context 'as data validator' do # {{{
  let(:pat) { create(:patient) }
  let(:more_values) { {} }

  let(:enc) do
    build(:encounter, {
      patient: pat,
      cpt_encounter_code: code,
      base_field => extract_values.deep_merge(more_values),
    }.merge(respond_to?(:root_values) ? root_values : {}))
  end

  let(:error_msgs) do
    enc_validate!
    enc.errors.messages[base_field].select{|t| t.include?("'#{error_field}'") }
  end

  let(:enc_lookups) do
    JSON.parse(File.read(Rails.root.join("db/lookups/encounter_lookups.json")))
  end

  def enc_validate!
    described_class.new.validate(enc)
  end

  def enc_lookup(key, name = nil)
    rs = enc_lookups[key]
    name ? rs.find{|r| r['key'] == name.to_s } : rs
  end

  def create_ref(keyprefix, name = '999', value = 'HeLLo')
    Ref::Lookup.create_with(keyname: name).find_or_create_by({
      group: 'BLAH',
      keyprefix: keyprefix,
      keyvalue: value,
    })
  end

  def extract_values
    case field.to_s
    when %r(^(\w+)\[(\w+)\]\.(\w+)$)
      {
        $1.to_sym => {
          name: $2,
          $3.to_sym => values[field]
        }
      }
    when %r(^(\w+)\[(\w+)\:(\w+)\]\.(\w+)$)
      {
        $1.to_sym => {
          $2.to_sym => $3,
          $4.to_sym => values[field]
        }
      }
    when %r(^(\w+)\.(\w+)$)
      {
        $1.to_sym => {
          $2.to_sym => values[field]
        }
      }
    else
      values
    end
  end

  def error_field
    case field.to_s
    when %r(^(\w+)\[(\w+)\]\.(\w+)$)
      "#{$1}.#{$3}"
    when %r(^(\w+)\[(\w+)\:(\w+)\]\.(\w+)$)
      "#{$1}.#{$4}"
    else
      field
    end
  end

  def self.include_validation_macros(base_field)
    let(:base_field) { base_field }
    generate_validation_macros self, base_field
  end

  def self.generate_validation_macros(subject, base_field)
    subject.define_singleton_method :has_pick_one_field_with_freetext do |field_name, ref_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        let(:ref) { create_ref(ref_name) }
        let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
        it_behaves_like 'asserts *pick one* field (with FREETEXT)'
      end
    end # }}}

    subject.define_singleton_method :has_pick_one_field_without_freetext do |field_name, ref_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        let(:ref) { create_ref(ref_name) }
        let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
        it_behaves_like 'asserts *pick one* field'
      end
    end # }}}

    subject.define_singleton_method :has_no_pick_one_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'not asserting *pick one* field'
      end
    end # }}}

    subject.define_singleton_method :has_pick_many_field_without_freetext do |field_name, ref_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        let(:ref) { create_ref(ref_name) }
        let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
        it_behaves_like 'asserts *pick many* field'
      end
    end # }}}

    subject.define_singleton_method :has_pick_many_field_with_freetext do |field_name, ref_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        let(:ref) { create_ref(ref_name) }
        let(:valid_option) { {name: ref.keyname, val: ref.keyvalue} }
        it_behaves_like 'asserts *pick many* field (with FREETEXT)'
      end
    end # }}}

    subject.define_singleton_method :has_no_pick_many_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'not asserting *pick many* field'
      end
    end # }}}

    subject.define_singleton_method :has_bool_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'asserts *bool* field'
      end
    end # }}}

    subject.define_singleton_method :has_no_bool_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'not asserting *bool* field'
      end
    end # }}}

    subject.define_singleton_method :has_text_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'asserts *text* field'
      end
    end # }}}

    subject.define_singleton_method :has_no_text_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'not asserting *text* field'
      end
    end # }}}

    subject.define_singleton_method :has_date_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'asserts *date* field'
      end
    end # }}}

    subject.define_singleton_method :has_time_field do |field_name| # {{{
      describe "handles #{base_field} :#{field_name}" do
        let(:field) { field_name }
        it_behaves_like 'asserts *time* field'
      end
    end # }}}
  end
end # }}}

shared_examples 'asserts *pick one* field (with FREETEXT)' do # {{{
  it_behaves_like 'asserts *pick one* field'

  context 'when assigned empty freetext' do
    let(:values) { {field => {name: 'FREETEXT', freetext: ""}} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid option)) }
  end

  context 'when assigned valid freetext' do
    let(:values) { {field => {name: 'FREETEXT', freetext: "HeLLo"}} }
    it { expect(error_msgs).to be_blank }
  end

end # }}}

shared_examples 'asserts *pick one* field (OPTIONAL)' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned matching' do
    let(:values) { {field => valid_option} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => {name: -1, val: "HeLLo"}} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid option)) }
  end
end # }}}

shared_examples 'asserts *pick one* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned matching' do
    let(:values) { {field => valid_option} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => {name: -1, val: "HeLLo"}} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid option)) }
  end
end # }}}

shared_examples 'asserts *bool* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned *YES*' do
    let(:values) { {field => {name: 'Y', val: 'Yes'}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned *NO*' do
    let(:values) { {field => {name: 'N', val: "No"}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned anything else' do
    let(:values) { {field => {name: 'U', val: "Unknown"}} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid option)) }
  end
end # }}}

shared_examples 'not asserting *bool* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'not asserting *pick one* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => {name: -1, val: "HeLLo"}} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'not asserting *pick many* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => []} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => [{name: -1, val: "HeLLo"}]} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *pick many* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => []} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned matching' do
    let(:values) { {field => [valid_option]} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => [{name: -1, val: "HeLLo"}]} }
    it { expect(error_msgs).to include(%('#{error_field}' has invalid option)) }
  end
end # }}}

shared_examples 'asserts *pick many* field (with FREETEXT)' do # {{{
  it_behaves_like 'asserts *pick many* field'

  context 'when assigned empty freetext' do
    let(:values) { {field => [{name: 'FREETEXT', freetext: ""}]} }
    it { expect(error_msgs).to include(%('#{error_field}' has invalid option)) }
  end

  context 'when assigned valid freetext' do
    let(:values) { {field => [{name: 'FREETEXT', freetext: "HeLLo"}]} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *pick many* field (OPTIONAL with FREETEXT)' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned matching' do
    let(:values) { {field => [valid_option]} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => [{name: -1, val: "HeLLo"}]} }
    it { expect(error_msgs).to include(%('#{error_field}' has invalid option)) }
  end

  context 'when assigned empty freetext' do
    let(:values) { {field => [{name: 'FREETEXT', freetext: ""}]} }
    it { expect(error_msgs).to include(%('#{error_field}' has invalid option)) }
  end

  context 'when assigned valid freetext' do
    let(:values) { {field => [{name: 'FREETEXT', freetext: "HeLLo"}]} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'not asserting *date* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned invalid date' do
    let(:values) { {field => "2017"} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *time* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned invalid time' do
    let(:values) { {field => "25:59"} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid time)) }
  end

  context 'when assigned time string' do
    let(:values) { {field => "23:59"} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *date* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned invalid date' do
    let(:values) { {field => "2017"} }
    it { expect(error_msgs).to include(%('#{error_field}' is not a valid date)) }
  end

  context 'when assigned date string' do
    let(:values) { {field => Date.today.to_s} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned datetime string' do
    let(:values) { {field => DateTime.now.to_s} }
    it { expect(error_msgs).to be_blank }
  end

end # }}}

shared_examples 'asserts *text* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned any string' do
    let(:values) { {field => "HEllo"} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'not asserting *text* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => ""} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *number* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => nil} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned non-int' do
    let(:values) { {field => "HEllo"} }
    it { expect(error_msgs).to include(%('#{error_field}' must be a number)) }
  end
end # }}}

shared_examples 'not asserting *number* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when blank' do
    let(:values) { {field => nil} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *hash-like* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned a hash-like' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned not a hash-like' do
    let(:values) { {field => "hello"} }
    it { expect(error_msgs).to include(%('#{error_field}' is invalid)) }
  end
end # }}}

shared_examples 'not asserting *hash-like* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned a hash-like' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned not a hash-like' do
    let(:values) { {field => "hello"} }
    it { expect(error_msgs).to be_blank }
  end
end # }}}

shared_examples 'asserts *relation* field' do # {{{
  context 'when missing' do
    let(:values) { {} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when blank' do
    let(:values) { {field => {}} }
    it { expect(error_msgs).to include(%('#{error_field}' can't be blank)) }
  end

  context 'when assigned matching' do
    let(:values) { {field => valid_id} }
    it { expect(error_msgs).to be_blank }
  end

  context 'when assigned non-matching' do
    let(:values) { {field => valid_id+999} }
    it { expect(error_msgs).to include(%('#{error_field}' is invalid)) }
  end
end # }}}

# vim:ts=2:bs=2:sw=2:et:fdm=marker
