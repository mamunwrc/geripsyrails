require 'rails_helper'

RSpec.describe Api::EncountersController, type: :controller do
  context "existing patient" do
    setup_patient!
    let(:json) { JSON.parse(response.body) }

    before do
      patient.encounters = FactoryGirl.create_list :encounter, 3
    end

    describe "PATCH update" do
      login_provider

      before do
        current_user.meta.patients << patient
      end

      describe "addendum" do
        let(:enc) { patient.encounters.first }

        before do
          patch :update, params: { patient_id: patient.id, id: enc.id, encounter: {id: enc.id, addendum: 'hello thar'} }
        end

        it "200s" do
          expect(response.status).to eql 200
        end

        it "should have addendum" do
          expect(enc.reload.addendums.size).to eql 1
        end
      end

      describe "facility_pos_code" do
        before :all do
          $__validators__ = Enc::Encounter._validate_callbacks.dup
          Enc::Encounter._validate_callbacks.clear
        end
        after :all do
          Enc::Encounter._validate_callbacks = $__validators__
        end
        let(:enc) { patient.encounters.first }
        let(:params) do
          {
            patient_id: patient.id,
            id: enc.id,
            encounter: {
              certify: true,
              id: enc.id,
              provider_id: provider.id,
              referral: { service_date: Date.today },
              certification: { sign_date: Date.today }
            }.merge(_params)
          }
        end
        let(:_params) { {} }

        before do
          patient.providers << provider
          patch :update, params: params
        end

        context 'not sent' do
          specify 'patient code doesnt change' do
            expect(patient.reload.facility_pos_code).to eql(31)
          end
        end

        context 'invalid code sent' do
          let(:_params) { {facility_pos_code: 4555} }

          specify 'patient code doesnt change' do
            expect(patient.reload.facility_pos_code).to eql(31)
          end
        end

        context 'valid code sent' do
          let(:_params) { {facility_pos_code: 32} }
          specify 'patient code updates' do
            expect(patient.reload.facility_pos_code).to eql(32)
          end
        end
      end
    end

    describe "GET index" do
      context "as super admin" do
        login_super_admin
        before do
          get :index, params: { patient_id: patient.id }
        end

        it "403s" do
          expect(response.status).to eql(403)
        end
      end

      context "as admin" do
        login_admin

        before do
          get :index, params: { patient_id: patient.id }
        end

        it "200s" do
          expect(response.status).to eql(200)
        end

        it "responds with encounter list" do
          expect(json.map {|enc| enc['id']}).to match_array(patient.encounters.pluck(:id))
        end
      end

      context "as reviewer"

      context "as provider" do
        context "accessing his patients records" do
          login_provider

          before do
            current_user.meta.patients << patient
            get :index, params: { patient_id: patient.id }
          end

          it "responds successfully" do
            expect(json.map {|enc| enc['id']}).to match_array(patient.encounters.pluck(:id))
          end
        end

        context "accessing non patient records" do
          login_provider

          before do
            get :index, params: { patient_id: patient.id }
          end

          it "responds with 404" do
            expect(response.status).to eql(404)
          end
        end
      end
    end

    describe "GET show" do
      before do
        login
        get :show, params: { patient_id: patient.id, id: patient.encounters.first.id }
      end

      context "as super admin" do
        let(:login) { login_super_admin! }

        it "403s" do
          expect(response.status).to eql 403
        end
      end

      context "as admin" do
        let(:login) { login_admin! }

        context "when accessible" do
          it "200s" do
            expect(response.status).to eql 200
          end
        end

        context "when patient not in practice" do
          let(:login) { login_admin! }
          setup_non_associated_patient!

          it "403s" do
            expect(response.status).to eql 403
          end
        end
      end

      context "as reviewer"

      context "as provider" do
        context "when accessible" do
          let(:login) do
            login_provider!
            current_user.meta.patients << patient
          end

          it "200s" do
            expect(response.status).to eql 200
          end
        end

        context "when patient not in practice" do
          let(:diff_practice) { FactoryGirl.create :practice}
          let(:facility) { FactoryGirl.create :facility, practice: diff_practice }
          let(:patient) { FactoryGirl.create :patient, practice: diff_practice, facility: facility }
          let(:login) { login_provider! }

          it "403s" do
            expect(response.status).to eql 403
          end
        end
      end
    end

    describe "POST create" do
      let(:enc_type) { '90791' }
      let(:payload) do
        {
          referral: {
            foo: 'bar'
          }
        }
      end

      before do
        login
        post :create, params: {
          patient_id: patient.id,
          cpt_encounter_code: enc_type,
          encounter: payload, # somehow this is mandatory
        } 
      end

      shared_examples "access denied" do
        it "403s" do
          expect(response.status).to eql 403
        end

        specify "access denied response" do
          expect(JSON.parse response.body).to include({"msg" => "You are not authorized to access this page."})
        end
      end

      shared_examples "success!" do
        it "200s" do
          expect(response.status).to eql 200
        end

        it "creates the encounter" do
          patient.encounters.order(:id).reload.last.tap do |enc|
            expect(enc.cpt_encounter_code).to eql(enc_type)
            expect(enc.referral).to_not be_blank
          end
        end
      end

      context "valid payload" do

        context "as super admin" do
          let(:login) { login_super_admin! }
          it_behaves_like "access denied"
        end

        context "as admin" do
          let(:login) { login_admin! }
          it_behaves_like "access denied"
        end

        context "as reviewer"

        context "as provider" do
          context "associated patient" do
            let(:login) { login_provider!; current_user.meta.patients << patient }

            context 'with *90791*' do
              let(:enc_type) { '90791' }
              it_behaves_like "success!"
            end

            context 'with *90832*' do
              let(:enc_type) { '90832' }
              it_behaves_like "success!"
            end

            context 'with *TP*' do
              let(:enc_type) { 'TP' }
              it_behaves_like "success!"
            end

            context 'with any other' do
              let(:enc_type) { 'watever' }

              it "422" do
                expect(response.status).to eql(422)
              end

              specify "error response" do
                expect(JSON.parse(response.body)).
                  to eq({"error" => "Unexpected encounter type 'watever'"})
              end
            end
          end

          context "non associated patient" do
            let(:login) { login_provider! }

            it "404s" do
              expect(response.status).to eql(404)
            end
          end
        end
      end
    end

    describe "PATCH update" do
      let(:encounter) { FactoryGirl.create(:encounter, patient: patient) }
      let(:payload) { {referral: {this: "is some stuff"}} }

      shared_examples "access denied" do
        it "403s" do
          expect(response.status).to eql 403
        end

        specify "access denied response" do
          expect(JSON.parse response.body).to include({"msg" => "You are not authorized to access this page."})
        end
      end

      shared_examples "conflicted" do
        it "409" do
          expect(response.status).to eql 409
        end

        specify "conflict response" do
          expect(JSON.parse response.body).
            to include({"error" => "Encounter##{encounter.id} is already certified"})
        end
      end

      shared_examples "success!" do
        it "200s" do
          expect(response.status).to eql 200
        end

        it "updates the encounter" do
          expect(patient.encounters.order(:id).reload.last.referral).to eql({"this" => 'is some stuff'})
        end
      end

      before do
        login
        patch(:update, params: { patient_id: patient.id, id: encounter.id, encounter: payload})
      end

      context "valid payload" do
        context "as super admin" do
          let(:login) { login_super_admin! }
          it_behaves_like "access denied"
        end

        context "as admin" do
          let(:login) { login_admin! }
          it_behaves_like "access denied"
        end

        context "as reviewer"

        context "as provider" do
          context "associated patient" do
            let :login do
              login_provider!
              certify! if respond_to?(:certify!)
              current_user.meta.patients << patient
            end

            def sign_encounter
              encounter.update(signed_on: 1.day.ago, signed_by: current_user)
            end

            context 'when not certified' do
              it_behaves_like "success!"
            end

            context 'when certified' do
              let(:certify!) { sign_encounter }
              it_behaves_like "conflicted"
            end

            context 'when certified only updating addendum' do
              let(:certify!) { sign_encounter }
              let(:payload) { {addendum: "Hey", addendum_user_id: current_user.id} }

              it "200s" do
                expect(response.status).to eql 200
              end

              it "updates the encounter" do
                expect(patient.encounters.order(:id).reload.last.addendums.pluck(:note)).
                  to include(payload[:addendum])
              end
            end
          end

          context "non-associated patient" do
            let(:login) { login_provider!}

            it_behaves_like "access denied"
          end
        end
      end
    end
  end

  context "no patient"
end
