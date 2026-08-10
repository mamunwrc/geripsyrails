require 'rails_helper'

RSpec.describe Api::PatientsController, type: :controller do
  context "existing patient" do
    setup_patient!

    let(:patient_id) { patient.id}

    shared_examples "success!" do
      it "200s" do
        expect(response.status).to eql 200
      end

      it "has patients" do
        json = JSON.parse response.body
        case json
        when Hash
          expect(json["id"]).to eql patient_id
        when Array
          expect(json.last["id"]).to eql patient_id
        else
          fail "wtf happened"
        end
      end
    end

    shared_examples "denied!" do
      it "403s" do
        expect(response.status).to eql 403
      end
    end

    shared_examples "empty" do
      it "200s" do
        expect(response.status).to eql 200
      end

      it "returns no patients" do
        expect(JSON.parse(response.body)).to be_empty
      end
    end

    describe "GET index" do
      before do
        patient #lets actually create a patient...
        login
        get :index
      end

      context "as super admin" do
        let(:login) { login_super_admin! }

        it_behaves_like "denied!"
      end

      context "as admin" do
        let(:login) { login_admin! }

        context "associated patient" do
          it_behaves_like "success!"
        end

        context "non-associated patients" do
          setup_non_associated_patient!
          it_behaves_like "empty"
        end
      end

      context "as reviewer"

      context "as provider" do

        context "associated patient" do
          let(:login) { login_provider!; current_user.meta.patients << patient }
          it_behaves_like "success!"
        end

        context "non-associated patient" do
          let(:login) { login_provider!}
          it_behaves_like "empty"
        end
      end
    end

    describe "GET show" do
      before do
        login
        get(:show, params: { id: patient.id })
      end

      context "as super admin" do
        let(:login) { login_super_admin! }

        it_behaves_like "denied!"
      end

      context "as admin" do
        let(:login) { login_admin! }

        context "associated patient" do
          it_behaves_like "success!"
        end

        context "non-associated patient" do
          setup_non_associated_patient!
          it_behaves_like "denied!"
        end
      end

      context "as reviewer"

      context "as provider" do

        context "associated patient" do
          let(:login) { login_provider!; current_user.meta.patients << patient }
          it_behaves_like "success!"
        end

        context "non-associated patient" do
          let(:login) { login_provider!}
          it_behaves_like "denied!"
        end
      end
    end

    describe "POST create" do
      shared_examples "creatable" do
        it_behaves_like "success!"

        it "creates the patient" do
          expect(current_user.meta.patients.last.first_name).to eql payload.first_name
        end
      end

      context "valid payload" do
        let(:patient_id) {Pat::Patient.find_by(first_name: payload.first_name).id}
        let(:payload) { FactoryGirl.build :patient, facility: facility}
        before do
          login
          post :create, params: { patient: payload.as_json}
        end

        context "as super admin" do
          let(:login) { login_super_admin! }
          it_behaves_like "denied!"
        end

        context "as admin" do
          let(:login) { login_admin! }
          it_behaves_like "creatable"
        end

        context "as reviewer"

        context "as provider" do
          let(:login) { login_provider! }
          it_behaves_like "creatable"
        end
      end
    end

    describe "PATCH update" do
      shared_examples "updateable" do
        it_behaves_like "success!"

        it "updates le patient" do
          expect(JSON.parse(response.body)["first_name"]).to eql payload.first_name
        end
      end

      context "valid payload" do
        let(:payload) { FactoryGirl.build(:patient) }
        before do
          login
          patch :update, params: { id: patient.id, patient: payload.as_json(only: [:first_name])}
        end

        context "as super admin" do
          let(:login) { login_super_admin! }
          it_behaves_like "denied!"
        end

        context "as admin" do
          let(:login) { login_admin! }

          context "associated patient" do
            it_behaves_like "updateable"
          end

          context "non-associated patient" do
            setup_non_associated_patient!
            it_behaves_like "denied!"
          end
        end

        context "as reviewer"

        context "as provider" do
          context "associated patient" do
            let(:login) { login_provider!; current_user.meta.patients << patient }
            it_behaves_like "updateable"
          end

          context "non-associated patient" do
            let(:login) { login_provider! }
            it_behaves_like "denied!"
          end
        end
      end
    end

    describe "POST notes" do
      let(:payload) { { id: patient.id, note_text: "Allo Lah" } }

      before do
        login
        post(:notes, params: payload)
      end

      shared_examples "taken note" do
        it "200s" do
          expect(response.status).to eql 200
        end

        it "creates the patient note" do
          expect(patient.notes.pluck(:text, :user_id)).
            to include([payload[:note_text], current_user.id])
        end
      end

      shared_examples "cant take note" do
        it "403" do
          expect(response.status).to eql 403
        end
      end

      context "as provider (with patient)" do
        let(:login) { login_provider!; current_user.meta.patients << patient }
        it_behaves_like "taken note"
      end

      context "as admin" do
        let(:login) { login_admin! }
        it_behaves_like "taken note"
      end

      context "as provider (without patient)" do
        let(:login) { login_provider! }
        it_behaves_like "cant take note"
      end

      context "as reviewer" do
        let(:login) { login_reviewer! }
        it_behaves_like "cant take note"
      end
    end

    describe 'GET encounter_dates' do
      setup_patient!
      login_provider

      def create_enc(opts, sd)
        build(:encounter, opts.merge(referral: {service_date: sd.to_s})).
          tap{|enc| enc.save validate: false } # cos it is just too hard to create a valid one
      end

      before do
        patient.providers << Usr::Provider.last
        3.times do
          begin
            create_enc(opts, Faker::Date.between(1.year.ago, Date.today))
          rescue ActiveRecord::RecordInvalid
            redo
          end
        end

      end
      let(:opts) {
        {
          patient_id: patient.id,
          provider_id: Usr::Provider.last.id,
          certify: true,
          cpt_encounter_code: '90832',
          certification: {
            sign_date: Date.today
          }
        }
      }
      let(:body) { JSON.parse(response.body) }
      context 'no dupable encounters' do
        before { get :encounter_dates, params: {id: patient.id} }
        it 'returns all encounter dates' do
          expect(patient.encounters.signed.map(&:service_date).compact.size).to eql(3)
          expect(JSON.parse(response.body)).to eq(patient.encounters.signed.map {|e| e.service_date.to_s})
        end
      end
      context 'with dupable encounters' do
        let(:tp_date) { '2010-01-01' }
        before do
          create_enc opts.merge(cpt_encounter_code: 'TP'), tp_date
          get :encounter_dates, params: {id: patient.id}
        end
        it 'returns all dates except TP' do
          expect(patient.encounters.signed.map(&:service_date).compact.size).to eql(4)
          expect(body.size).to eql(3)
          expect(body).to_not include(tp_date)
        end
      end
    end
  end
end
