require 'rails_helper'

RSpec.describe UploadHpBillingToS3Job, type: :job do

  describe '#perform' do
    let(:enc) { create(:encounter, shipped_hp_billing: billing) }
    let(:task) { UploadHpBillingToS3Job.new }

    shared_examples 'skip uploading' do
      specify do
        expect(task).to_not receive(:s3_upload)
        task.perform enc.id
      end
    end

    shared_examples 'doing upload' do
      it 'uploads to s3' do
        expect(task).to receive(:s3_upload).
          with("hp_billing/#{billing[fields.file]}", billing[fields.xml])
        task.perform enc.id 
      end

      it 'updates #shipped_hp_billing *s3*' do
        expect(task).to receive(:s3_upload).
          and_return(OpenStruct.new(bucket: 'bucket_lah', key: 'key_lah'))
        task.perform enc.id

        expect(enc.reload.shipped_hp_billing[fields.s3]).to eq({
          "bucket" => 'bucket_lah',
          "key" => "key_lah",
        })
      end

      it 'removes #shipped_hp_billing *xml*' do
        expect(task).to receive(:s3_upload).
          and_return(OpenStruct.new(bucket: 'bucket_lah', key: 'key_lah'))
        task.perform enc.id

        expect(enc.reload.shipped_hp_billing[fields.xml]).to be_nil
      end
    end

    shared_examples 'upload isnt required' do
      context 'cos #shipped_hp_billing *filename* is blank' do
        let(:billing) { { fields.xml => '<xml>xml_lah</xml>' } }
        it_behaves_like 'skip uploading'
      end

      context 'cos #shipped_hp_billing *xml* is blank' do
        let(:billing) { { fields.file => 'file_lah' } }
        it_behaves_like 'skip uploading'
      end

      context 'cos #shipped_hp_billing *s3* is present' do
        let(:billing) do
          {
            fields.file => 'file_lah',
            fields.xml => '<xml>xml_lah</xml>',
            fields.s3 => {
              bucket: 'xyz',
              key: 'abc',
            }
          }
        end
        it_behaves_like 'skip uploading'
      end
    end

    shared_examples 'upload is required' do
      let(:billing) do
        {
          fields.file => 'file_lah',
          fields.xml => '<xml>xml_lah</xml>',
        }
      end
      it_behaves_like 'doing upload'
    end

    describe 'regular uploads' do
      let(:fields) { OpenStruct.new(s3: 's3', file: 'filename', xml: 'xml') }
      it_behaves_like 'upload isnt required'
      it_behaves_like 'upload is required'
    end

    describe 'secondary uploads' do
      let(:fields) { OpenStruct.new(s3: 'secondary_s3', file: 'secondary_filename', xml: 'secondary_xml') }
      it_behaves_like 'upload isnt required'
      it_behaves_like 'upload is required'
    end
  end
end
