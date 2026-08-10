require 'rails_helper'

RSpec.describe Pat::Patient, type: :model do
  def mk_encounter(type, date)
    patient.encounters.build({
      cpt_encounter_code: type,
      certification: {
        sign_date: date,
      },
      referral: {
        service_date: date
      },
      certification: {
        sign_date: date
      }
    }).tap do |enc|
      allow(DateTime).to receive(:now).and_return(date)
      enc.certify = true
      enc.save(validate: false)
    end
  end

  let(:patient) { create(:patient) }

  pending '#testing_provider' do
    let(:proA) { create(:provider) }
    let(:patient) { create(:patient, opts) }
    let(:opts) { {} }

    it "has no associated providers by default" do
      expect(patient.providers.count).to be_zero
    end

    context 'when adding' do
      before do
        patient.update_attributes(testing_provider_id: proA.id)
      end

      it 'adds pat into providers list' do
        expect(patient.provider_ids).to eql([proA.id])
      end
    end

    context 'when removing' do
      let(:_opts) { {testing_provider_id: proA.id} }

      context 'when pro is primary' do
        let(:opts) { _opts.merge(primary_provider_id: proA.id) }

        before do
          patient.providers << proA
          patient.update_attributes(testing_provider_id: nil)
        end

        it 'does not remove patient from pros list' do
          expect(patient.provider_ids).to eql([proA.id])
        end
      end

      context 'when pro is not primary' do
        let(:opts) { _opts }

        before do
          patient.update_attributes(testing_provider_id: nil)
        end

        it 'rms patient from pros list' do
          expect(patient.provider_ids).to be_blank
        end
      end
    end
    context 'when changing'
  end

  describe '#needs_tp?' do
    context "has unsigned TP" do
      before { patient.encounters.create cpt_encounter_code: 'TP' }

      it "does not need a TP" do
        expect(patient).to_not be_needs_tp
      end
    end

    context "has TP older than 3 months" do
      before do
        mk_encounter "TP", 4.months.ago
      end

      it "needs a new TP" do
        expect(patient).to be_needs_tp
      end
    end

    context "has TP less than 3 months old" do
      before do
        mk_encounter "TP", 2.months.ago
      end

      it "doesnt need a new TP" do
        expect(patient).to_not be_needs_tp
      end
    end

    context "has no TP" do
      context "has other encounters older than 3 months" do
        context "has more than 5 previous encounters" do
          before do
            5.upto(9){|i| mk_encounter('90791', i.months.ago) }
          end

          context "6th is past 3 months" do
            before { mk_encounter('90791', 4.months.ago) }

            it "needs a new TP" do
              expect(patient).to be_needs_tp
            end
          end

          context "6th isnt past 3 months" do
            before { mk_encounter('90791', 2.months.ago) }

            it "doesnt need a new TP" do
              expect(patient).to_not be_needs_tp
            end
          end
        end

        context "has 5 or fewer previous encounters" do
          before do
            mk_encounter "90791", 6.months.ago
          end

          it "doesnt need a new TP" do
            expect(patient).to_not be_needs_tp
          end
        end

        context "has other encounters less than 3 months old" do
          before do
            mk_encounter "90791", 2.months.ago
          end

          it "doesnt need a new TP" do
            expect(patient).to_not be_needs_tp
          end

        end
        context "has no previous encounters" do
          it "doesnt need a new TP" do
            expect(patient).to_not be_needs_tp
          end
        end
      end

    end
  end

  describe '#assign_next_tp' do

    context "has unsigned TP" do
      before { patient.encounters.create cpt_encounter_code: 'TP' }

      it "assign as blank" do
        expect(patient.next_tp).to be_blank
      end
    end

    context "has signed TP" do
      before { mk_encounter "TP", 1.months.ago }

      it "assign as 3.months later" do
        expect(patient.next_tp.to_i).to eq(-2.months.ago.beginning_of_day.to_i)
      end
    end

    context "has no TP" do
      context "has more than 5 previous encounters" do
        before { 4.upto(9){|i| mk_encounter('90791', i.months.ago) } }

        it "assign as 3.months later of 6th" do
          expect(patient.next_tp.to_i).to eq(1.months.ago.beginning_of_day.to_i)
        end
      end

      context "has less than 5 previous encounters" do
        before { 6.upto(9){|i| mk_encounter('90791', i.months.ago) } }

        it "assign as infinite future with 5 minus N offset" do
          expect(patient.next_tp.to_i).
            to eq((Pat::Patient::INFINITE_NEXT_TP + (10-4).years).to_i)
        end
      end

      context "has no previous encounters" do
        it "assign as blank" do
          expect(patient.next_tp).to be_blank
        end
      end
    end
  end

  describe '.pending_tp' do
    let!(:tier1_patients) { (1..2).map {|i| create(:patient, next_tp: i.days.ago) } }
    let!(:tier3_patients) { (1..2).map {|i| create(:patient, next_tp: Time.now + i.days) } }
    let!(:other_patients) { [create(:patient, next_tp: nil)] }

    let!(:tier2_patients) do
      (1..2).map do |i|
        create(:patient, next_tp: Pat::Patient::INFINITE_NEXT_TP + i.year)
      end
    end

    specify do
      expect(Pat::Patient.pending_tp.pluck(:id)).to eq([
        *tier1_patients.sort_by(&:next_tp).map(&:id),
        *tier2_patients.sort_by(&:next_tp).map(&:id),
        *tier3_patients.sort_by(&:next_tp).map(&:id),
      ])
    end
  end

  describe 'no insurance provider alert' do
    include ActiveJob::TestHelper

    after { clear_enqueued_jobs }
    before { patient.update opts }
    around do |ex|
      ENV['INSURANCE_CONTACT_EMAIL'] = 'foo@foo.com'
      ex.run
      ENV['INSURANCE_CONTACT_EMAIL'] = nil
    end

    let(:patient) { create(:patient) }
    let(:opts) { {} }

    context 'when field changed' do
      let(:opts) { {primary_insurance_id: ::Pat::Insurance::OTHER_INSURANCE_ID } }
      it 'enqueues the task' do
        expect(InsuranceAlertJob).to have_been_enqueued.with(patient.id)
      end
    end
    context 'when field did not change' do
      let(:opts) { { primary_insurance_id: 1 }}
      it 'does not send the alert' do
        expect(InsuranceAlertJob).to_not have_been_enqueued
      end
    end
  end

  describe '#reprimarize!' do
    let(:pro1) { create(:provider) }

    before do
      patient.providers = provider_list
      patient.update primary_provider_id: pro1.id
    end

    context 'when other provider' do
      let(:pro2) { create(:provider) }
      let(:pro3) { create(:provider) }
      let(:provider_list) { [pro1, pro2, pro3] }

      def do_enc(proid, covering=false)
        mk_encounter( '90832', Date.today ).tap {|e|
          e.referral.covering = covering
          e.provider_id = proid;
          e.signed_by = proid;
          e.save(validate: false)
        }
      end

      context 'when patient has signed note from other' do
        context 'when other is in patients provider list' do
          context 'when not "covering"' do
            it 'updates primary_provider_id to latest note signer' do
              # add a note for pro 3 and then 1 for pro1 to reset primary_pro_id
              do_enc(pro3.id)
              do_enc(pro1.id)

              expect { patient.reprimarize! }.to change { patient.primary_provider_id }.from(pro1.id).to(pro3.id)
            end
          end

          context 'when "covering"' do
            it 'ignores the covered note' do
              do_enc(pro3.id, true)
              expect { patient.reprimarize! }.to change { patient.primary_provider_id }.from(pro1.id).to(pro2.id)
            end
          end
        end

        context 'when other not in patients provider list' do
          it 'updates primary_provider to next in list' do
            do_enc(create(:provider).id)
            expect { patient.reprimarize! }.to change { patient.primary_provider_id }.from(pro1.id).to(pro2.id)
          end
        end
      end

      context 'when patient has no signed note from other' do
        it 'updates primary_provider to next in list' do
          do_enc(pro1.id)
          expect { patient.reprimarize! }.to change { patient.primary_provider_id }.from(pro1.id).to(pro2.id)
        end
      end
    end

    context 'when no other provider' do
      let(:provider_list) { [pro1] }

      it 'updates primary_provider to nil' do
        expect { patient.reprimarize! }.to change { patient.primary_provider_id }.from(pro1.id).to(nil)
      end
    end
  end

end
