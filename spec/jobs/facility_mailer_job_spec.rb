require 'rails_helper'

RSpec.describe FacilityMailerJob, type: :job do
  describe "#perform" do
    let(:practice) { create(:practice) }
    let!(:admin) { create(:admin, practice: practice) }
    let(:facility) { create(:facility, practice: practice) }
    let(:pdf_contact) { create(:facility_contact, export_format: :pdf, facility: facility) }
    let(:docx_contact) { create(:facility_contact, export_format: :docx, facility: facility) }
    let(:partial_pdf_contact) { create(:facility_contact, export_format: :pdf, export_type: :partial, facility: facility) }
    let(:partial_docx_contact) { create(:facility_contact, export_format: :docx, export_type: :partial, facility: facility) }

    let(:task) { described_class.new }
    before do
      allow(task).to receive(:send_mail).and_return(true)
      allow(task).to receive(:cleanup).with(any_args).and_return([])
    end

    around do |ex|
      PdfGenerator::Encounter.define_generator("FAKE") {}
      DocxGenerator::Encounter.define_generator("FAKE") {templates({default: '90791.template.docx'})}
      ex.run
      PdfGenerator::Encounter.generators.delete("FAKE")
      DocxGenerator::Encounter.generators.delete("FAKE")
      FileUtils.rm Dir["/tmp/encounters-*.{pdf,zip}"]
    end

    context 'when encounters signed yesterday exists' do
      let(:provider) { create(:provider, practice: practice) }
      let!(:encounter) { create(:encounter, cpt_encounter_code: "FAKE", signed_on: Date.yesterday, signed_by: provider.id, patient: create(:patient, facility: facility)) }

      context 'when pdf and docx contacts exist' do
        before {
          pdf_contact
          docx_contact
        }
        it 'generates the attachments' do
          task.perform facility.id
          expect(File.file?(task.send(:path_for, facility, :pdf))).to be
          expect(File.file?(task.send(:path_for, facility, :zip))).to be
          expect(File.file?(task.send(:path_for, facility, :pdf, :partial))).to_not be
          expect(File.file?(task.send(:path_for, facility, :zip, :partial))).to_not be
        end

        context 'with partial contacts' do
          before {
            partial_pdf_contact
            partial_docx_contact
          }
          it 'generates the attachments' do
            task.perform facility.id
            expect(File.file?(task.send(:path_for, facility, :pdf))).to be
            expect(File.file?(task.send(:path_for, facility, :zip))).to be
            expect(File.file?(task.send(:path_for, facility, :pdf, :partial))).to be
            expect(File.file?(task.send(:path_for, facility, :zip, :partial))).to be
          end
        end
      end
    end

  end
end
