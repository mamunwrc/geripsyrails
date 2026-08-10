require 'rails_helper'

RSpec.describe Enc::Encounter, type: :model do
  before :all do
    # need Ref::Lookup seed data
    Rails.application.load_seed
  end

  def mk_encounter(service_date, save = true, **extras)
    build(:encounter, {
      patient: patient1,
      certify: certify,
      signed_on: Date.today,
      certification: { sign_date: service_date },
      referral: { service_date: service_date }
    }.merge(extras)).tap{|enc| enc.save if save }
  end

  def build_note(code, data={})
    mk_encounter(Date.today, false, data.merge(cpt_encounter_code: code))
  end

  def _90832; build_note('90832', _90832_extras); end
  def _90832_ic; build_note('90832', _90832_extras('90832, 90785', '4')); end
  def _90834; build_note('90832', _90832_extras(90834, 2));end
  def _90834_ic; build_note('90832', _90832_extras('90834, 90785', 5));end
  def _90837; build_note('90832', _90832_extras(90837, 3));end
  def _90837_ic; build_note('90832', _90832_extras('90837, 90785', 6)) ;end
  def _90832_untimed; build_note('90832', _90832_extras('Psychotherapy untimed', 7)) ;end
  def _90847; build_note('90832', _90832_extras(90847, 8)) ;end
  def _90846; build_note('90832', _90832_extras(90846, 9)) ;end
  def _90791; build_note('90791'); end
  def _90853; build_note('90853'); end
  def existing_note(note); note.tap {|enc| enc.save(validate: false) }; end
  def _90832_extras(val=90832, name=1)
    {
      therapeutic_communication: {
        service_conducted: {
          val: "(#{val})",
            name: name.to_s
        }
      }
    }
  end


  let(:patient1) { create(:patient) }

  describe '#charge_units' do
    context 'for a non-testing note' do
      subject(:note) { build(:encounter) }

      it 'is always 1' do
        expect(note.charge_units).to eql(1)
      end
    end

    context 'for a testing note' do
      pending "CHARGE UNITS IS HACKED TOGETHER IN BG JOB. PLZ FIX" do
        subject(:note) do
          build :encounter, {
            cpt_encounter_code: '96116',
            patient: patient1,
            referral: {
              minutes: minutes
            }
          }
        end

        let(:units) { note.charge_units }

        shared_examples_for 'invalid' do
          it 'has no units' do
            expect(units).to eql(0)
          end
        end

        context 'when minutes blank' do
          let(:minutes) { nil }
          it_behaves_like 'invalid'
        end

        context 'when minutes zero' do
          let(:minutes) { 0 }
          it_behaves_like 'invalid'
        end

        context 'when < 31 provided' do
          let(:minutes) { 30 }
          it_behaves_like 'invalid'
        end

        context 'when minutes > 30 & < 91' do
          let(:minutes) { 75 }

          it 'charges 1 unit' do
            expect(note.charge_units).to eql(1)
          end
        end

        context 'when minutes > 90 & < 151' do
          let(:minutes) { 91 }

          it 'charges 2 units' do
            expect(note.charge_units).to eql(2)
          end
        end
      end
    end
  end

  describe 'validations' do
    describe 'dup service date' do
      before :each do
        existing
      end

      let(:certify) {true}

      before do
        enc.valid?
      end

      shared_examples 'dup date blocker' do
        it "has a service date" do
          expect(enc.errors[:referral]).to_not include("'service_date' can't be blank")
        end

        it "blocks dup'd date" do
          expect(enc.errors[:referral]).to include("'service_date' is duplicated")
        end
      end

      shared_examples 'dup date allowed' do
        it "has a service date" do
          expect(enc.errors[:referral]).to_not include("'service_date' can't be blank")
        end

        it "allows dup'd date" do
          expect(enc.errors[:referral]).to_not include("'service_date' is duplicated")
        end
      end

      context 'existing 90832' do
        let(:existing) { existing_note(_90832) }

        context '90791 with same date' do
          let(:enc) { _90791 }
          it_behaves_like 'dup date blocker'
        end

        context '90832 with same date' do
          let(:enc) { _90832 }
          it_behaves_like 'dup date blocker'
        end

        context '90834 with same date' do
          let(:enc) { _90834 }
          it_behaves_like 'dup date blocker'
        end

        context '90837 with same date' do
          let(:enc) { _90837 }
          it_behaves_like 'dup date blocker'
        end

        context '90832 IC with same date' do
          let(:enc) { _90832_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90834 IC with same date' do
          let(:enc) { _90834_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90837 IC with same date' do
          let(:enc) { _90837_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90846 with same date' do
          let(:enc) { _90846 }
          it_behaves_like 'dup date allowed'
        end

        context '90847 with same date' do
          let(:enc) { _90847 }
          it_behaves_like 'dup date allowed'
        end

        context '90853 with same date' do
          let(:enc) { _90853 }
          it_behaves_like 'dup date allowed'
        end
      end

      context 'existing 90846' do
        let(:existing) { existing_note(_90846) }

        context '90846 with same date' do
          let(:enc) { _90846 }
          it_behaves_like 'dup date blocker'
        end

        context '90847 with same date' do
          let(:enc) { _90847 }
          it_behaves_like 'dup date blocker'
        end

        context '90832 with same date' do
          let(:enc) { _90832 }
          it_behaves_like 'dup date allowed'
        end

        context '90834 with same date' do
          let(:enc) { _90834 }
          it_behaves_like 'dup date allowed'
        end

        context '90837 with same date' do
          let(:enc) { _90837 }
          it_behaves_like 'dup date allowed'
        end

        context '90832 IC with same date' do
          let(:enc) { _90832_ic }
          it_behaves_like 'dup date allowed'
        end

        context '90834 IC with same date' do
          let(:enc) { _90834_ic }
          it_behaves_like 'dup date allowed'
        end

        context '90837 IC with same date' do
          let(:enc) { _90837_ic }
          it_behaves_like 'dup date allowed'
        end

        context '90853 with same date' do
          let(:enc) { _90853 }
          it_behaves_like 'dup date allowed'
        end

        context '90791 with same date' do
          let(:enc) { _90791 }
          it_behaves_like 'dup date blocker'
        end
      end

      context 'existing 90853' do
        let(:existing) { existing_note(_90853) }

        context '90791 with same date' do
          let(:enc) { _90791 }
          it_behaves_like 'dup date blocker'
        end

        context '90853 with same date' do
          let(:enc) { _90853 }
          it_behaves_like 'dup date blocker'
        end

        context '90846 with same date' do
          let(:enc) { _90846 }
          it_behaves_like 'dup date allowed'
        end

        context '90847 with same date' do
          let(:enc) { _90847 }
          it_behaves_like 'dup date allowed'
        end

        context '90832 with same date' do
          let(:enc) { _90832 }
          it_behaves_like 'dup date allowed'
        end

        context '90834 with same date' do
          let(:enc) { _90834 }
          it_behaves_like 'dup date allowed'
        end

        context '90837 with same date' do
          let(:enc) { _90837 }
          it_behaves_like 'dup date allowed'
        end

        context '90832 IC with same date' do
          let(:enc) { _90832_ic }
          it_behaves_like 'dup date allowed'
        end

        context '90834 IC with same date' do
          let(:enc) { _90834_ic }
          it_behaves_like 'dup date allowed'
        end

        context '90837 IC with same date' do
          let(:enc) { _90837_ic }
          it_behaves_like 'dup date allowed'
        end
      end

      context 'existing 90791' do
        let(:existing) { existing_note(_90791) }

        context '90791 with same date' do
          let(:enc) { _90791 }
          it_behaves_like 'dup date blocker'
        end

        context '90832 with same date' do
          let(:enc) { _90832 }
          it_behaves_like 'dup date blocker'
        end

        context '90834 with same date' do
          let(:enc) { _90834 }
          it_behaves_like 'dup date blocker'
        end

        context '90837 with same date' do
          let(:enc) { _90837 }
          it_behaves_like 'dup date blocker'
        end

        context '90832 IC with same date' do
          let(:enc) { _90832_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90834 IC with same date' do
          let(:enc) { _90834_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90837 IC with same date' do
          let(:enc) { _90837_ic }
          it_behaves_like 'dup date blocker'
        end

        context '90846 with same date' do
          let(:enc) { _90846 }
          it_behaves_like 'dup date blocker'
        end

        context '90847 with same date' do
          let(:enc) { _90847 }
          it_behaves_like 'dup date blocker'
        end

        context '90853 with same date' do
          let(:enc) { _90853 }
          it_behaves_like 'dup date blocker'
        end
      end
    end

  end

  describe "screenings" do
    describe 'uniquify screening types' do
      let(:certify) { false }
      subject(:encounter) { mk_encounter(Date.today) }
      let(:orig_axes) { [{val: "3"}, {val: "2"}, {val: "3"}, {val: "4"}].map(&:with_indifferent_access) }

      before do
        subject.update_attributes(screenings_attributes: [{screening_type: 'bcrs', axes: orig_axes}])
      end

      context 'one screening type' do
        let(:screenings) { subject.screenings.where(screening_type: 'bcrs') }
        context 'first of screening type' do
          it "saves the screening" do
            expect(screenings.count).to eql(1)
            expect(screenings.first.axes.map(&:with_indifferent_access)).to eql(orig_axes)
          end
        end

        context 'second' do
          let(:new_axes) { [{val: "1"}, {val: "2"}, {val: "3"}, {val: "4"}].map(&:with_indifferent_access) }
          it 'updates the existing record' do
            subject.update_attributes(screenings_attributes: [{screening_type: 'bcrs', axes: new_axes}])
            expect(screenings.count).to eql(1)
            expect(screenings.first.axes.map(&:with_indifferent_access)).to eql(new_axes)
          end
        end
      end
    end
  end

  describe 'hooks' do
    before do
      Enc::Encounter::DATA_VALIDTORS.each do |v|
        expect_any_instance_of(v).
          to receive(:validate).at_least(:once).with(any_args)
      end
    end

    describe 'setting Patient#has90791' do
      let(:certify) { true }
      subject(:encounter) {
        mk_encounter(Date.today, false, {
          cpt_encounter_code: code,
          provider_id: 1
        })
      }

      context 'when 90791' do
        let(:code) { '90791' }

        it 'sets Patient#has90791' do
          expect(subject.patient).to receive(:has90791!).and_return(true)
          subject.save
        end
      end

      context 'when non-90791' do
        let(:code) { '90832' }

        it 'doesnt set Patient#has90791' do
          expect(subject.patient).not_to receive(:has90791!)
          subject.save
        end
      end
    end

    describe '#primary_provider_id' do
      let(:certify) { true }
      let(:practice) { create(:practice) }
      let(:provider) { create(:provider, practice: practice) }
      let(:provider2) { create(:provider, practice: practice) }
      let(:encounter) { mk_encounter(Date.today, false, cpt_encounter_code: code, provider_id: pro_id) }

      before do
        patient1.providers = [provider, provider2]
        patient1.update primary_provider_id: provider.id
      end

      context '90832' do
        let(:code) { '90832' }
        let(:pro_id) { provider.id }

        before do
          encounter.provider_id = provider2.id
        end

        it 'updates primary when "covering" not set' do
          encounter.save
          expect(patient1.reload.primary_provider_id).to eql(provider2.id)
        end

        it 'doesnt change primary when "covering" set' do
          encounter.referral.covering = true
          encounter.save
          expect(patient1.reload.primary_provider_id).to eql(provider.id)
        end
      end

      context 'non-90832' do
        let(:code) { '90791' }
        let(:pro_id) { provider.id }

        it 'updates #primary_provider' do
          encounter.save
          expect(patient1.reload.primary_provider_id).to eql(provider.id)
        end
      end
    end
  end


  describe 'HP XML' do
    before :all do
      Pat::Insurance.delete_all
    end
    let(:insurance) { create(:insurance) }
    let(:encounter) { create(:encounter, opts) }
    let(:patient) { create(:patient, primary_insurance_id: insurance.hp_id_code, primary_insurance_number: 'aoeuaoeu', dob: 30.years.ago) }
    let(:provider) { create(:provider, practice: create(:practice)) }
    let(:valid_opts) {
      {
        patient_id: patient.id,
        signed_on: DateTime.now,
        signed_by: provider.id,
        cpt_encounter_code: '90791',
        referral: { service_date: DateTime.now },
        diagnosis: { primary: {name: 'XYZ'} }
      }
    }

    describe '#build_hp_xml' do
      context 'valid encounter' do
        let(:opts) { valid_opts }
        let(:xml) do <<-EOF
<?xml version="1.0"?>
<encounter>
  <patient_code>#{patient.id}</patient_code>
  <patient_first_name>#{patient.first_name}</patient_first_name>
  <patient_last_name>#{patient.last_name}</patient_last_name>
  <patient_dob>#{patient.dob.to_date}</patient_dob>
  <patient_gender>#{patient.gender}</patient_gender>
  <patient_ssn/>
  <patient_address1>#{patient.facility.address1}</patient_address1>
  <patient_address2>#{patient.facility.address2}</patient_address2>
  <patient_city>#{patient.facility.city}</patient_city>
  <patient_state>#{patient.facility.state}</patient_state>
  <patient_zip>#{patient.facility.zip}</patient_zip>
  <patient_phone>#{patient.facility.work_phone}</patient_phone>
  <primary_ins_code>#{insurance.hp_code}</primary_ins_code>
  <primary_ins_name>#{insurance.name}</primary_ins_name>
  <primary_ins_id>#{patient.primary_insurance_number}</primary_ins_id>
  <secondary_ins_code/>
  <secondary_ins_name/>
  <secondary_ins_id/>
  <tertiary_ins_code/>
  <tertiary_ins_name/>
  <tertiary_ins_id/>
  <facility>#{patient.facility.hp_code}</facility>
  <signer>#{provider.hp_code}</signer>
  <cpt_code>90791</cpt_code>
  <icd10>XYZ</icd10>
  <service_date>#{encounter.service_date.to_date}</service_date>
  <charge_units>1</charge_units>
  <referring_dr> </referring_dr>
</encounter>
EOF
        end

        it "is valid" do
          expect(encounter).to be_valid_for_charge
        end

        it "generates the correct data" do
          expect(encounter.build_hp_xml.to_xml).to eql(xml)
        end

        it "cannot be generated more than once" do
          xml_builder = encounter.build_hp_xml
          xml_builder.build!
          expect(xml_builder.to_xml).to eql(xml)
        end

        it 'doesnt have secondary_xml' do
          expect(encounter.build_hp_xml.to_secondary_xml).to be_nil
        end

        context 'when encounter is 9611x with extra charge_units' do
          #let(:opts) do
          #  valid_opts.merge({
          #    cpt_encounter_code: '96116',
          #    referral: { minutes: 125 }
          #  })
          #end

          pending 'has 2 charge units' do
            expect(encounter.build_hp_xml.to_xml).to match(/<charge_units>2<\/charge_units>/)
          end
        end

        context 'when note is testing' do
          let(:opts) {valid_opts.merge(cpt_encounter_code: '96116')}

          it "adds referring_dr" do
            expect(encounter.signer.hp_code).to_not be_nil
            expect(encounter.build_hp_xml.to_xml).to match(/<referring_dr>#{encounter.signer.hp_code}<\/referring_dr>/)
          end
        end

        context 'when encounter has secondary pos' do
          let(:opts) { valid_opts.merge(facility_pos_code: 32) }
          let(:fac_alt_code) { 99 }
          let(:_xml) { xml.sub(/<facility>.*<\/facility>/, "<facility>FAC099</facility>") }

          context 'when facility has secondary code' do
            before do
              patient.facility.update(hp_alt_pos_code: fac_alt_code)
            end

            it "builds xml with alt facility code" do
              expect(encounter.build_hp_xml.to_xml).to eql(_xml)
            end
          end

          context 'when facility doesnt have secondary code' do
            it { expect { encounter.build_hp_xml }.to raise_error(Adm::Facility::NoAltPOSCodeError) }
          end
        end

        context 'when encounter has interactive complexity' do
          before do
            encounter.functional_status = {}
            encounter.functional_status.interactive_complexity = { name: 'Y' }
          end

          let(:hp_xml) { encounter.build_hp_xml }
          let(:secondary_xml) { xml.dup.gsub(/90791/, '90785') }

          it 'generates base xml' do
            expect(hp_xml.to_xml).to eql(xml)
          end

          it 'generates secondary xml' do
            expect(hp_xml.to_secondary_xml).to eql(secondary_xml)
          end
        end

        context 'when encounter has 90840' do
          let(:opts) {
            valid_opts.merge({
              cpt_encounter_code: '90839',
              plan: { crisis_additional_time: { name: 'Y' }, crisis_additional_time_minutes: { name: 'more' }}
            })
          }
          let(:hp_xml) { encounter.build_hp_xml }
          let(:secondary_xml) { xml.dup.gsub(/90791/, '90840') }

          it 'generates base xml' do
            expect(hp_xml.to_xml).to eql(xml.sub(/90791/,'90839'))
          end

          it 'generates secondary xml' do
            expect(hp_xml.to_secondary_xml).to eql(secondary_xml)
          end
        end
      end

      context 'already shipped to hp encounters' do
        let(:opts) { valid_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar'}) }

        it 'throws an error when shipping to hp already done' do
          expect { encounter.build_hp_xml }.to raise_error(Enc::Encounter::AlreadyShippedToHpError)
        end
      end

      context 'invalid encounters' do
        let(:opts) { valid_opts}

        shared_examples_for 'invalid for charge' do
          it 'isnt valid for charge' do
            expect(encounter).to_not be_valid_for_charge 
          end

          it 'throws an error when building charge xml' do
            expect { encounter.build_hp_xml }.to raise_error(Enc::Encounter::NotValidForChargeError)
          end

        end
        context 'missing patient_id' do
          let(:opts) { valid_opts.merge(patient_id: nil) }
          it_behaves_like 'invalid for charge'
        end
        context 'missing dob' do
          before { patient.update dob: nil }
          it_behaves_like 'invalid for charge'
        end
        context 'missing signer' do
          let(:opts) { valid_opts.merge(signed_by: nil) }
          it_behaves_like 'invalid for charge'
        end
        context 'missing prim ins' do
          before { patient.update primary_insurance_id: nil }
          it_behaves_like 'invalid for charge'
        end
        context 'non-chargeable note' do
          let(:opts) { valid_opts.merge(cpt_encounter_code: 'TP') }
          it_behaves_like 'invalid for charge'
        end
        context 'missing diagnosis' do
          let(:opts) { valid_opts.merge(diagnosis: {}) }
          it_behaves_like 'invalid for charge'
        end
      end

      describe '#build_hp_xml!' do
        let(:opts) { valid_opts }
        let(:bomb) { Class.new(StandardError) }
        let!(:now) do
          Time.parse("2017-01-26 17:58:29 +0800").
            tap{|t| allow(Time).to receive(:now).and_return(t) }
        end

        def must_save_shipped_hp_billing!
          encounter.shipped_hp_billing.tap do |billing|
            expect(billing[:filename]).to eq("#{provider.hp_code}-#{now.to_f}.xml")
            expect(billing[:xml]).to include("<cpt_code>#{encounter.encounter_type}</cpt_code>")
          end
        end

        context 'when not provided a proc' do
          it 'saves generated xml to #shipped_hp_billing' do
            encounter.build_hp_xml!
            must_save_shipped_hp_billing!
          end

          context 'when encounter has interactive complexity' do
            before do
              encounter.functional_status = { interactive_complexity: { name: 'Y' } }
              encounter.build_hp_xml!
            end

            it 'has ic keys in hp billing' do
              must_save_shipped_hp_billing!.tap do |billing|
                expect(billing[:secondary_filename]).to eq("#{provider.hp_code}-#{now.to_f}.xml")
                expect(billing[:secondary_xml]).to include('<cpt_code>90785</cpt_code>')
              end
            end
          end

          context 'when encounter has 90840' do
            before do
              encounter.build_hp_xml!
            end
            let(:opts) {
              valid_opts.merge({
                cpt_encounter_code: '90839',
                plan: { crisis_additional_time: { name: 'Y' }, crisis_additional_time_minutes: { name: 'more' }}
              })
            }

            it 'has ic keys in hp billing' do
              must_save_shipped_hp_billing!.tap do |billing|
                expect(billing[:secondary_filename]).to eq("#{provider.hp_code}-#{now.to_f}.xml")
                expect(billing[:secondary_xml]).to include('<cpt_code>90840</cpt_code>')
              end
            end
          end
        end

        context 'when provided a proc that doesnt bomb' do
          it 'saves generated xml to #shipped_hp_billing' do
            encounter.build_hp_xml! { :doesnt_bomb! }
            must_save_shipped_hp_billing!
          end
        end

        context 'when provided a proc that bombs' do
          it 'doesnt save generated xml to #shipped_hp_billing' do
            expect{ encounter.build_hp_xml! { raise bomb } }.to raise_error(bomb)
            expect(encounter.reload.shipped_hp_billing).to be_blank
          end
        end

        context 'when regular billing entry already present but not ic' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar'}) }
          before { encounter.functional_status = { interactive_complexity: { name: 'Y' } } }

          it 'only invokes block for ic billing' do
            encounter.build_hp_xml! do |billing|
              expect(billing.filename).to include(".xml")
              expect(billing.xml).to include('<cpt_code>90785</cpt_code>')
            end
          end

          it 'doesnt overwrite existing' do
            encounter.build_hp_xml!

            encounter.reload.shipped_hp_billing.tap do |billing|
              expect(billing['filename']).to eq('foo')
              expect(billing['xml']).to eq('bar')
            end
          end
        end

        context 'when ic billing entry already present but not regular' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {secondary_filename: 'foo', secondary_xml: 'bar'}) }
          before { encounter.functional_status = { interactive_complexity: { name: 'Y' } } }

          it 'only invokes block for regular billing' do
            encounter.build_hp_xml! do |billing|
              expect(billing.filename).to include(".xml")
              expect(billing.xml).to include("<cpt_code>#{encounter.encounter_type}</cpt_code>")
            end
          end

          it 'doesnt overwrite existing' do
            encounter.build_hp_xml!

            encounter.reload.shipped_hp_billing.tap do |billing|
              expect(billing['secondary_filename']).to eq('foo')
              expect(billing['secondary_xml']).to eq('bar')
            end
          end
        end
      end

      describe '#shipped_to_hp?' do
        context 'having :filename & :xml' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar'}) }
          it { expect(encounter).to be_shipped_to_hp }
        end
        context 'having :filename & :s3' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar'}) }
          it { expect(encounter).to be_shipped_to_hp }
        end
        context 'having only :filename' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {filename: 'foo'}) }
          it { expect(encounter).to_not be_shipped_to_hp }
        end
        context 'having only :xml' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {xml: 'foo'}) }
          it { expect(encounter).to_not be_shipped_to_hp }
        end
        context 'having only :s3' do
          let(:opts) { valid_opts.merge(shipped_hp_billing: {s3: 'foo'}) }
          it { expect(encounter).to_not be_shipped_to_hp }
        end

        context 'when encounter has int comp' do
          let(:secondary_opts) { valid_opts.merge(functional_status: { interactive_complexity: { name: 'Y' }}) }

          context 'having all *xml* opts' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_filename: 'abc', secondary_xml: 'xyz'}) }
            it { expect(encounter).to be_shipped_to_hp }
          end
          context 'having all *s3* opts' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_filename: 'abc', secondary_s3: 'xyz'}) }
            it { expect(encounter).to be_shipped_to_hp }
          end

          context 'missing :secondary_filename with :secondary_xml' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_xml: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
          context 'missing :secondary_filename with :secondary_s3' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_s3: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end

          context 'missing :secondary_xml with :secondary_filename' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_filename: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
          context 'missing :secondary_s3 with :secondary_filename' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_filename: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
        end

        context 'when encounter has 90840' do
          let(:secondary_opts) {
            valid_opts.merge(cpt_encounter_code: '90839', plan: {
              crisis_additional_time: { name: 'Y' },
              crisis_additional_time_minutes: { name: 'more' }
            })
          }

          context 'having all *xml* opts' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_filename: 'abc', secondary_xml: 'xyz'}) }
            it { expect(encounter).to be_shipped_to_hp }
          end
          context 'having all *s3* opts' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_filename: 'abc', secondary_s3: 'xyz'}) }
            it { expect(encounter).to be_shipped_to_hp }
          end

          context 'missing :secondary_filename with :secondary_xml' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_xml: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
          context 'missing :secondary_filename with :secondary_s3' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_s3: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end

          context 'missing :secondary_xml with :secondary_filename' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', xml: 'bar', secondary_filename: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
          context 'missing :secondary_s3 with :secondary_filename' do
            let(:opts) { secondary_opts.merge(shipped_hp_billing: {filename: 'foo', s3: 'bar', secondary_filename: 'xyz'}) }
            it { expect(encounter).to_not be_shipped_to_hp }
          end
        end
      end
    end
  end

  describe 'skipping enc_data validations' do
    before :all do
      $__validators__ = Enc::Encounter._validate_callbacks.dup
      Enc::Encounter._validate_callbacks.clear
    end
    after :all do
      Enc::Encounter._validate_callbacks = $__validators__
    end

    describe 'code modifiers' do
      let(:certify) { true }

      before :each do
        existing
        note.valid?
      end

      describe '#add_modifier' do
        let(:existing) { existing_note(_90832) }
        let(:note) {_90832}

        context 'with empty :code_modifier' do
          it 'returns regular code' do
            expect(existing.add_modifier(true, 90832) {|c| [c, existing.code_modifier].join('-')}).to eql(90832)
          end
        end

        context 'with code modifier' do
          it 'adds modifier' do
            existing.code_modifier = 95
            expect(existing.add_modifier(true, 90832) {|c| [c, existing.code_modifier].join('-')}).to eql("90832-95")
          end
        end
      end

      context 'when existing 90832' do
        let(:existing) { existing_note(_90832) }

        context 'adding family therapy' do
          let(:note) { _90846 }
          it "adds modifier 59 to 90832" do
            expect(existing.reload.code_modifier).to eql('59')
          end

          it "adds modifier 59 to 90846" do
            expect(note.code_modifier).to eql('59')
          end
        end

        context 'adding group therapy' do
          let(:note) { _90853 }
          it "adds modifier 59 to 90832" do
            expect(existing.reload.code_modifier).to eql('59')
          end

          it "adds modifier 59 to 90853" do
            expect(note.code_modifier).to eql('59')
          end
        end
      end

      context 'when existing 90846' do
        let(:existing) { existing_note(_90846) }
        let(:note) { _90832 }

        it "adds modifier 59 to 90846" do
          expect(existing.reload.code_modifier).to eql('59')
        end

        it "adds modifier 59 to 90832" do
          expect(note.code_modifier).to eql('59')
        end
      end
      context 'when existing 90791' do
        let(:existing) { existing_note(_90791) }
        let(:note) { _90846 }

        it "does not add the modifier to 90791" do
          expect(existing.reload.code_modifier).to be_blank
        end

        it "does not add the modifier to followup" do
          expect(note.code_modifier).to be_blank
        end
      end
      context 'when existing 90853' do
        let(:existing) { existing_note(_90853) }
        let(:note) { _90832 }

        it "adds the modifier to 90853" do
          expect(existing.reload.code_modifier).to eql('59')
        end

        it "adds the modifier to followup" do
          expect(note.code_modifier).to eql('59')
        end
      end
    end

    describe 'facility_pos_code' do
      let(:pro) { create(:provider) }
      let(:certify) { nil }
      let(:note) {
        build_note('90832', _90832_extras.merge({
          facility_pos_code: code, certify: true
        }))
      }
      shared_examples_for 'doesnt change patient' do
        specify do
          expect { note.save }.to_not change { note.patient.facility_pos_code }
        end
      end

      before do
        patient1.providers << pro
        note.provider_id = pro.id
      end

      context 'when same as pat' do
        let(:code) { Pat::Patient::DEFAULT_FAC_POS }
        it_behaves_like 'doesnt change patient'
      end
      context 'when invalid' do
        let(:code) { 99999 }
        it_behaves_like 'doesnt change patient'
      end
      context 'when valid and different' do
        let(:code) { 32 }
        it 'changes patient code' do
          expect { note.save }.to change { note.patient.facility_pos_code }.from(31).to(32)
        end
      end
      context 'when not provided' do
        let(:code) { nil }
        it_behaves_like 'doesnt change patient'
      end

      context 'when existing signed note with more recent DOS' do
        let(:existing) {
          build_note('90832', _90832_extras.merge({
            facility_pos_code: code, certify: true
          }))
        }
        let(:code) { nil }

        it "doesnt update patient pos" do
          existing.provider_id = pro.id
          existing.facility_pos_code = 32
          existing.save

          note.referral.service_date = Date.yesterday.to_s
          note.facility_pos_code = 31

          expect { note.save }.to_not change { patient1.facility_pos_code }
        end
      end
    end
  end
end

