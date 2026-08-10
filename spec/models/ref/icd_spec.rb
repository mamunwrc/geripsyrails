require 'rails_helper'

RSpec.describe Ref::Icd, type: :model do
  before :all do
    Ref::Icd.destroy_all
  end

  describe '.import' do
    let(:override) { false }
    let(:existing) { create_list(:ref_icd, 3, group: 1) }
    let(:_payload) do
      Array.new(3).map do
        {
          'code' => Faker::Number.decimal(3,2),
          'desc' => Faker::Lorem.sentence
        }
      end
    end
    let(:payload) { :_payload }

    before do
      Ref::Icd.import(1, payload, override)
    end

    context 'when rm set' do
      let(:override) {true}

      context 'when payload contains existing' do
        let(:resent) { {'code' => existing.last.icd, 'desc' => existing.last.description} }
        let(:payload) { _payload + [resent] }

        it 'adds payload' do
          expect(Ref::Icd.count).to eql(6)
          expect(Ref::Icd.where(icd: payload.map {|i| i['code']}).count).to eql(payload.size)
        end

        specify 'payload marked as active' do
          expect(Ref::Icd.active.pluck(:icd)).to match_array(payload.pluck('code'))
        end

        specify 'non-sent existing marked inactive' do
          expect(Ref::Icd.inactive.pluck(:icd)).to eql(existing[0..1].pluck(:icd))
        end
        context 'when existing in payload was previously inactive' do
          let(:existing) { create_list(:ref_icd, 1, group: 1, is_active: false) }

          it 'updates to active' do
            expect(Ref::Icd.count).to eql(4)
            expect(Ref::Icd.pluck(:is_active)).to eql([true, true, true, true])
          end
        end
      end
    end
  end
end

