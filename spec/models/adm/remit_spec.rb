require 'rails_helper'

RSpec.describe Adm::Remit, type: :model do
  describe '.import' do
    subject(:remit) { build(:remit, remit_batch: batch, practice: practice, content: file).import! }
    let(:batch) { create(:remit_batch, practice: practice) }
    let(:file) { file_fixture("remit-#{remit_file}.txt").read }
    let(:practice) { create(:practice) }

    context 'when status posted' do
      let(:provider) { create(:provider, hp_account: 8, practice: practice) }
      let(:remit_file) { 'posted' }

      it 'is persisted' do
        expect(remit).to be_persisted
      end

      it 'has content' do
        expect(remit.content).to eql(file)
      end

      it 'has status posted' do
        expect(remit).to be_status_posted
      end

      it 'has a provider' do
        provider
        expect(remit.provider).to eql(provider)
      end

      it 'has posted date' do
        expect(remit.posted_on.to_s).to eql("2017-11-15 10:01:19 UTC")
      end

      it 'has batch #' do
        expect(remit.batch).to eql('11152017RICHARDS')
      end

      context 'when file previously imported' do
        it 'returns the prior remit' do
          provider
          first = build(:remit, remit_batch: batch, practice: practice, content: file).import!
          expect(remit).to eql(first)
        end
      end
    end

    context 'when status unposted with charge' do
      let(:remit_file) { 'unposted-charge' }

      it 'is persisted' do
        expect(remit).to be_persisted
      end

      it 'has content' do
        expect(remit.content).to eql(file)
      end

      it 'has status unposted' do
        expect(remit).to be_status_unposted
      end

      it 'has no provider' do
        expect(remit.provider).to be_nil
      end

      it 'has posted date' do
        expect(remit.posted_on.to_s).to eql("2017-11-12 02:37:25 UTC")
      end

      it 'has batch #' do
        expect(remit.batch).to eql('11122017A')
      end
    end

    context 'when status unposted without charge' do
      let(:remit_file) { 'unposted-no-charge' }

      it 'is not persisted' do
        expect(remit).to_not be_persisted
      end

      it 'has content' do
        expect(remit.content).to eql(file)
      end

      it 'has no status' do
        expect(remit.status).to be_nil
      end

      it 'is not a valid record' do
        expect(remit).to_not be_valid
      end
    end
  end
end
