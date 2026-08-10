require 'rails_helper'

RSpec.describe ShipBillingToHpJob, type: :job do
  describe '#perform' do
    let!(:now) do
      Time.parse("2017-01-24 05:35:06 +0800").
        tap{|t| allow(Time).to receive(:now).and_return(t) }
    end

    let(:insurance) { create(:insurance) }
    let(:encounter) { create(:encounter, opts) }
    let(:encounter2) { create(:encounter, opts.merge(signed_by: nil)) }
    let(:patient) { create(:patient, primary_insurance_id: insurance.hp_id_code, primary_insurance_number: 'aoeuaoeu', dob: 30.years.ago) }
    let(:provider) { create(:provider, practice: create(:practice)) }
    let(:opts) {
      {
        patient_id: patient.id,
        signed_on: DateTime.now,
        signed_by: provider.id,
        cpt_encounter_code: '90791',
        referral: { service_date: DateTime.now },
        diagnosis: { primary: {name: 'XYZ'} }
      }
    }

    let(:task) { ShipBillingToHpJob.new }
    let(:path) { ShipBillingToHpJob::DIR.join("#{provider.hp_code}-#{now.to_f}.xml") }

    before { allow(task).to receive(:sftp_upload).with(any_args) }

    context 'with regular shipping ONLY' do
      it 'writes xml to RAILS_ROOT/tmp/billing' do
        task.perform encounter.id
        expect(File.read(path)).to match(%r(.*<encounter>.*)m)
      end

      it 'uploads xml via sftp' do
        expect(task).to receive(:sftp_upload).with(path)
        task.perform encounter.id
      end

      it 'marks encounter as shipped' do
        task.perform encounter.id
        expect(encounter.reload).to be_shipped_to_hp
      end

      it 'cannot ship an already shipped encounter' do
        encounter.update shipped_hp_billing: {filename: 'foo', xml: 'bar'}
        expect{ task.perform(encounter.id) }.
          to raise_error(Enc::Encounter::AlreadyShippedToHpError)
      end

      it 'cannot ship an invalid for charge encounter' do
        expect{ task.perform(encounter2.id) }.
          to raise_error(Enc::Encounter::NotValidForChargeError)
      end
    end

    context 'with secondary shipping as well' do
      before do
        encounter.functional_status = { interactive_complexity: { name: 'Y' } }
        encounter.shipped_hp_billing = { filename: 'foo', xml: 'bar' }
        encounter.save
      end

      it 'writes secondary xml to RAILS_ROOT/tmp/billing' do
        task.perform encounter.id
        expect(File.read(path)).to include("<cpt_code>90785</cpt_code>")
      end
    end
  end
end
