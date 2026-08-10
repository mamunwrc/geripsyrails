require 'rails_helper'

RSpec.describe Grp::Group, type: :model do
  let!(:practice) { create(:practice) }
  let(:proA) { create(:provider, practice: practice) }
  let(:group) { create(:group, practice: practice) }

  describe 'validations' do
    context 'name' do
      context 'present' do
        it 'is valid' do
          expect(build(:group, practice: practice)).to be_valid
        end
      end

      context 'missing' do
        it 'is invalid' do
          expect(described_class.new(practice: practice)).to be_invalid
        end
      end
    end
  end

  describe 'updating patients' do
    let(:proB) { create(:provider, practice: practice) }
    let(:patientA) { create(:patient, has90791: true) }
    let(:patientB) { create(:patient, has90791: true) }
    let(:patientC) { create(:patient, has90791: true) }

    before do
      patientA.providers << proA
      patientB.providers << proB
      group.providers << proA
      group.providers << proB
    end

    context 'provider accessible patient' do
      it 'updates patient list' do
        ids = [patientA.id, patientB.id]
        group.incoming_patient_ids = ids
        group.save
        expect(group.reload.patients.pluck(:id)).to eql(ids)
      end
    end
    context 'non-provider accessible patient' do
      it 'updates patient list with accessible patients only' do
        ids = [patientA.id, patientC.id]
        group.incoming_patient_ids = ids
        group.save
        expect(group.reload.patients.pluck(:id)).to eql([patientA.id])
      end
    end
    context 'adding patient missing 90791' do
      before do
        patientA.update(has90791: false)
      end

      it 'doesnt allow patient to be added' do
        group.incoming_patient_ids = [patientA.id]
        group.save
        expect(group.reload.patients).to be_blank
      end
    end
  end

  describe 'adding a provider from a different practice' do
    let(:proB) { create(:provider, practice: create(:practice)) }
    before do
      group.providers << proA
    end

    it do
      expect { group.providers << proB }.to raise_error(ActiveRecord::RecordNotSaved)
    end
  end
end
