require 'rails_helper'

RSpec.describe Adm::Facility, type: :model do
  describe '#hp_code'  do
    let(:practice) { FactoryGirl.create(:practice) }
    let(:encounter) { FactoryGirl.build(:encounter) }

    context 'without main or alt code' do
      let(:facility) { practice.facilities.create(name: 'fac 1') }

      it 'formats hp code with id' do
        expected = "FAC00#{facility.id}"
        expect(facility.hp_code_for(encounter)).to eq(expected)
      end
    end

    context 'with alt code' do
      let(:facility) { practice.facilities.create(name: 'fac 2', hp_alt_pos_code: 78) }

      it 'formats hp code with alt id' do
        encounter.facility_pos_code = 32
        expect(facility.hp_code_for(encounter)).to eq("FAC078")
      end
    end

    context 'when main code in encounter with different main hp id in fac' do
      let(:facility) { practice.facilities.create(name: 'fac 2', hp_alt_pos_code: 78, hp_main_pos_code: 22) }

      it 'formats hp code with :hp_main_pos_code' do
        expect(facility.hp_code_for(encounter)).to eq("FAC022")
      end
    end
  end
end
