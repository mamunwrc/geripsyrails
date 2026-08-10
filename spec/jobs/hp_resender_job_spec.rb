require 'rails_helper'

RSpec.describe HpResenderJob, type: :job do
  describe '#perform' do
    let(:encounter) { create(:encounter, opts) }
    let(:insurance) { create(:insurance) }
    let(:patient) { create(:patient, primary_insurance_id: insurance.hp_id_code, primary_insurance_number: '123456', dob: 30.years.ago) }
    let(:provider) { create(:provider, practice: create(:practice) ) }
    let(:signed_on) { DateTime.now }
    let(:opts) {
      {
        patient_id: patient.id,
        signed_on: signed_on,
        signed_by: provider.id,
        cpt_encounter_code: '90791',
        referral: { service_date: service_date },
        diagnosis: { primary: { name: 'XYZ' } }
      }
    }
    let(:task) { described_class.perform_later }

    around do |ex|
      ENV['SHIP_BILLING_TO_HP'] = 'true'
      ENV.delete('DEBUG_EMAIL')
      ex.run
      ENV.delete('SHIP_BILLING_TO_HP')
    end

    before do
      ENV['SHIP_BILLING_TO_HP'] = 'true'
      allow_any_instance_of(ShipBillingToHpJob).to receive(:sftp_upload).with(any_args)
      encounter
      perform_enqueued_jobs { task }
    end

    after do
      ENV['SHIP_BILLING_TO_HP'] = 'false'
      clear_enqueued_jobs
      clear_performed_jobs
    end

    around do |ex|
      ENV['SHIP_BILLING_TO_HP'] = 'true'
      ex.run
      ENV['SHIP_BILLING_TO_HP'] = nil
    end

    context 'with unshipped valid encounters in the valid date range' do
      let(:service_date) { Date.yesterday }
      it 'enqueues the shipping task' do
        expect(encounter.reload).to be_shipped_to_hp
      end
    end
    context 'with unshipped valid encounters outside of the valid date range' do
      let(:service_date) { "2016-01-01" }
      it 'doesnt enqueue the task' do
        expect(encounter.reload).to_not be_shipped_to_hp
      end
    end
    context 'with unshipped invalid encounters in the valid date range' do
      let(:service_date) { Date.yesterday }
      let(:signed_on) { nil }
      it 'doesnt enqueue the task' do
        expect(encounter.reload).to_not be_shipped_to_hp
      end
    end
  end
end
