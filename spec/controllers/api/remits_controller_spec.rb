require 'rails_helper'

RSpec.describe Api::RemitsController, type: :controller do
  describe 'POST import' do
    let(:practice) { create(:practice, remit_token: 'xxx') }
    let(:provider) {create(:provider, hp_account: 8, practice: practice)}
    let(:posted_remit) {file_fixture('remit-posted.txt').read}
    let(:unposted_charge_remit) {file_fixture('remit-unposted-charge.txt').read}
    let(:unposted_remit) {file_fixture('remit-unposted-no-charge.txt').read}
    let(:req_ip) { '1.2.3.4' }
    let(:files) do
      [
        {filename: 'posted.txt', content: posted_remit},
        {filename: 'unposted.txt', content: unposted_remit},
        {filename: 'unposted-charge.txt', content: unposted_charge_remit},
        {content: 'remit missing filename'},
        'remit sent in invalid format'
      ]
    end

    before do
      allow(Date).to receive(:today).and_return(Date.new(2017,1,1))
      request.remote_addr = req_ip
      provider
      post :import, params: {token: token, files: files}
    end

    context 'without authentication' do
      context 'no token' do
        let(:token) { nil }
        it '403s' do
          expect(response.status).to eql(403)
        end
      end
      context 'bad token' do
        let(:token) { 'abc' }
        it '403s' do
          expect(response.status).to eql(403)
        end
      end
    end

    context 'with authentication' do
      let(:token) {'xxx'}

      it '200s' do
        expect(response.status).to eql(200)
      end

      describe 'response' do
        let(:resp) { Hashie::Mash.new(JSON.parse(response.body)) }

        context 'no files sent' do
          let(:files) { [] }

          it 'responds with error' do
            expect(resp.status).to eql('error')
          end

          it 'responds with error message' do
            expect(resp.error.msg).to eql('no files sent')
          end

          it 'doesnt create a batch' do
            expect(Adm::RemitBatch.count).to be_zero
          end
        end

        context 'files sent' do
          it 'responds with success' do
            expect(resp.status).to eql('ok')
          end

          it 'doesnt have any request errors' do
            expect(resp.error).to be_blank
          end

          describe 'batch' do
            let(:batch) { Adm::RemitBatch.find_by(batch_date: Date.today) }

            it 'stores the request ip' do
              expect(batch.ip.to_s).to eql(req_ip)
            end

            it 'has a practice id' do
              expect(batch.practice_id).to eql(practice.id)
            end

            it 'has the request token' do
              expect(batch.token).to eql(token)
            end
          end

          describe 'posted' do
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'posted.txt' }}

            it 'is ok' do
              expect(rresp['status']).to eql('ok')
            end
            it 'is posted' do
              expect(rresp['remit']['status']).to eql('posted')
            end
            it 'has provider' do
              expect(rresp['remit']['provider_id']).to eql(provider.id)
            end
          end

          describe 'unposted with charge' do
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'unposted-charge.txt' }}

            it 'is ok' do
              expect(rresp['status']).to eql('ok')
            end
            it 'is unposted' do
              expect(rresp['remit']['status']).to eql('unposted')
            end
            it 'has no provider' do
              expect(rresp['remit']['provider_id']).to be_nil
            end
          end

          describe 'unposted without charge' do
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'unposted.txt' }}

            it 'is ok' do
              expect(rresp['status']).to eql('ok')
            end
            it 'has no remit' do
              expect(rresp['remit']).to eql({'id' => nil, 'status' => nil, 'provider_id' => nil, 'posted_on' => nil, 'batch' => nil})
            end
          end

          describe 'sent with no filename' do
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'UNKNOWN3' }}

            it 'is not ok' do
              expect(rresp['status']).to eql('error')
            end
            it 'has an error message' do
              expect(rresp['errors']).to eql([{'msg' => 'file has no filename'}])
            end
            it 'has no remit' do
              expect(rresp['remit']).to be_nil
            end
          end
          describe 'sent with no content' do
            # NOTE either rails or rspec was merging
            # this into another hash in :files O_o
            # so running it separately here...
            let(:files) {[{filename: 'missing-content.txt'}]}
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'missing-content.txt' }}

            it 'is not ok' do
              expect(rresp['status']).to eql('error')
            end
            it 'has an error message' do
              expect(rresp['errors']).to eql([{'msg' => 'file contains no content'}])
            end
            it 'has no remit' do
              expect(rresp['remit']).to be_nil
            end
          end
          describe 'sent with invalid format' do
            let(:rresp) { resp['remits'].find {|r| r['filename'] == 'UNKNOWN4' }}

            it 'is not ok' do
              expect(rresp['status']).to eql('error')
            end
            it 'has an error message' do
              expect(rresp['errors']).to eql([{'msg' => 'file in invalid format'}])
            end
            it 'has no remit' do
              expect(rresp['remit']).to be_nil
            end
          end
        end
      end
    end
  end
end
