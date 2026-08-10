require 'rails_helper'

RSpec.describe DailyRemitShipperJob, type: :job do
  describe '#perform' do
    let(:provider) { create(:provider, practice: create(:practice)) }
    let(:provider2) { create(:provider, practice: provider.practice)}
    let(:task) { DailyRemitShipperJob.new }
    let(:_batch1) { create_list(:remit_with_data, 3, provider: provider, practice_id: provider.practice_id, remit_batch: create(:remit_batch)) }
    let(:_batch2) { create_list(:remit_with_data, 2, provider: provider2, practice_id: provider2.practice_id, remit_batch: create(:remit_batch)) }
    let(:batch1) { Adm::Remit.where(id: _batch1) }
    let(:batch2) { Adm::Remit.where(id: _batch2) }
    let(:b1attach) do
      batch1.map {|r| {string: r.content, filename: "eob-report-#{r.posted_on.to_date}", filetype: '.txt'}}
    end
    let(:b2attach) do
      batch2.map {|r| {string: r.content, filename: "eob-report-#{r.posted_on.to_date}", filetype: '.txt'}}
    end

    around(:all) do |ex|
      ENV['SHIP_REMITS'] = '1'
      ENV['REMIT_UNSHIPPED_EMAIL'] = 'foo@bar.com'
      ex.run
      ENV['SHIP_REMITS'] = nil
      ENV['REMIT_UNSHIPPED_EMAIL'] = nil
    end

    it 'ships via sendinc' do
      expect(task).to receive(:ship_remits).once.
        with(provider.user.email, b1attach).
        and_return(true)

      expect(task).to receive(:ship_remits).once.
        with(provider2.user.email, b2attach).
        and_return(true)

      task.perform
    end

    it 'sets remits as shipped' do
      expect(task).to receive(:ship_remits).once.
        with(provider.user.email, b1attach).
        and_return(true)

      expect(task).to receive(:ship_remits).once.
        with(provider2.user.email, b2attach).
        and_return(true)

      expect { task.perform }.to change {
        batch1.reload.pluck(:shipped)
      }.from([false, false, false]).to([true, true, true])
    end

    describe 'when unshippable remits present' do
      let(:unshippable) { create(:remit_with_data, practice_id: provider.practice_id, remit_batch: batch1.first.remit_batch) }
      let(:unship_att) {
        [
          {
            string: unshippable.content,
            filename: "UNSHIPPED-report-#{unshippable.posted_on.to_date}",
            filetype: '.txt'
          }
        ]
      }

      it 'ships the unshippable to REMIT_UNSHIPPED_EMAIL' do
        expect(task).to receive(:ship_remits).once.
          with(provider.user.email, b1attach).
          and_return(true)

        expect(task).to receive(:ship_remits).once.
          with(provider2.user.email, b2attach).
          and_return(true)

        expect(task).to receive(:ship_remits).once.
          with(ENV['REMIT_UNSHIPPED_EMAIL'], unship_att, false).
          and_return(true)

        task.perform
      end

      it 'sets unshippables as shipped' do
        expect(task).to receive(:ship_remits).once.
          with(provider.user.email, b1attach).
          and_return(true)

        expect(task).to receive(:ship_remits).once.
          with(provider2.user.email, b2attach).
          and_return(true)

        expect(task).to receive(:ship_remits).once.
          with(ENV['REMIT_UNSHIPPED_EMAIL'], unship_att, false).
          and_return(true)

        expect { task.perform }.to change {
          unshippable.reload.shipped
        }.from(false).to(true)
      end
    end
  end
end

