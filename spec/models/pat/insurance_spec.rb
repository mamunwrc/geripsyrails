require 'rails_helper'

RSpec.describe Pat::Insurance, type: :model do
  let(:ins) do
    if respond_to?(:opts)
      build(:insurance, opts)
    else
      build(:insurance)
    end
  end

  shared_examples_for 'valid' do
    it 'is valid' do
      expect(ins).to be_valid
    end
  end

  shared_examples_for 'invalid' do
    it 'is invalid' do
      expect(ins).to_not be_valid
    end
  end

  describe '#hp_id_code' do
    let(:opts) { {hp_id_code: code} }

    describe 'validations' do
      context 'when code is 0' do
        let(:code) { 0 }
        it_behaves_like 'invalid'
      end

      context 'when code is > 0 and unique' do
        let(:code) { 999 }
        it_behaves_like 'valid'
      end

      context 'when code is not unique' do
        let(:code) { 20 }
        before { create(:insurance, hp_id_code: code) }
        it_behaves_like 'invalid'
      end

      context 'when incoming_hp_code contains a number' do
        let(:opts) { {incoming_hp_code: "INS0076" } }

        it_behaves_like 'valid'

        it 'saves successfully' do
          ins.save
          expect(Pat::Insurance.find_by(hp_id_code: 76)).to be_present
        end
      end

      context 'when incoming_hp_code doesnt contain a number' do
        let(:opts) { {incoming_hp_code: "lolwut" } }
        it_behaves_like 'invalid'
      end
    end
  end

  describe '#name' do
    describe 'validations' do
      context 'when name missing' do
        before { ins.name = "" }
        it_behaves_like 'invalid'
      end

      context 'when name not unique' do
        let(:opts) { {name: "awesome insurance inc" } }
        before { create(:insurance, opts) }
        it_behaves_like 'invalid'
      end
    end
  end
end
