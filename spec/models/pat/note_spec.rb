require 'rails_helper'

RSpec.describe Pat::Note, type: :model do
  describe 'validating' do
    let(:note) { build(:patient_note, attrs) }

    describe 'missing patient' do
      let(:attrs) { {patient: nil} }
      specify do
        expect(note).to_not be_valid
        expect(note.errors[:patient]).to include("can't be blank")
      end
    end

    describe 'missing user' do
      let(:attrs) { {user: nil} }
      specify do
        expect(note).to_not be_valid
        expect(note.errors[:user]).to include("can't be blank")
      end
    end

    describe 'everything there' do
      let(:attrs) { {} }
      it { expect(note).to be_valid }
    end
  end
end
