require 'rails_helper'

RSpec.describe Usr::License, type: :model do
  describe "#state" do
    subject {FactoryGirl.build :license}

    context "valid state" do

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "invalid state" do
      it "is not valid" do
        subject.state = "FOO"
        expect(subject).to_not be_valid
        expect(subject.state).to be_nil
      end

      it "is required" do
        subject.state = nil
        expect(subject).to_not be_valid
      end
    end
  end

  describe "#number" do
    subject {FactoryGirl.build :license}

    it "is required" do
      subject.number = nil
      expect(subject).to_not be_valid
    end
  end
end
