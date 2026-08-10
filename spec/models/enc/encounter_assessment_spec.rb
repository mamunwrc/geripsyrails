require 'rails_helper'

RSpec.describe Enc::EncounterAssessment, type: :model do
  context "validity" do
    subject(:assessment) {Enc::EncounterAssessment.new}

    describe "invalid assessment" do
      before { subject.valid? }

      specify { expect(subject).to_not be_valid }
      it "requires an encounter_id" do
        expect(subject.errors[:encounter_id]).to eql(["can't be blank"])
      end
    end

    describe "valid assessment" do
      before { subject.encounter_id = 1}

      specify { expect(subject).to be_valid }
    end
  end
end

