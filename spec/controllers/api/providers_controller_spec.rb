require 'rails_helper'

RSpec.describe Api::ProvidersController, type: :controller do
  context "providers exist" do
    let!(:providers) { FactoryGirl.create_list(:provider, 3, practice: current_practice) }
    let(:json) { JSON.parse response.body }

    shared_examples "success" do
      it "200s" do
        expect(response.status).to eql(200)
      end
    end

    shared_examples "denied" do
      it "403s" do
        expect(response.status).to eql(403)
      end
    end

    describe "GET testings" do
      before do
        login_provider!
        get :testings, params: {id: current_user.meta_id}
      end

      it 'contains all providers' do
        expect(Usr::Provider.count).to eql(4)
        expect(json.size).to eql(3)
      end

      specify 'minus current pro' do
        ids = json.pluck("id")
        expect(ids).to_not include(current_user.meta_id)
        expect(ids).to eql(providers.pluck(:id))
      end
    end

    describe "GET index" do
      before do
        login
        get :index
      end

      shared_examples "has providers" do
        it_behaves_like "success"

        it "returns all providers" do
          expect(json.size).to eql(3)
        end
      end

      context "when super admin" do
        let(:login) { login_super_admin! }

        it_behaves_like "denied"
      end

      context "when admin" do
        let(:login) { login_admin! }

        it_behaves_like "has providers"
      end

      context "when reviewer"

      context "when provider" do
        let(:login) { login_provider! }

        it_behaves_like "denied"
      end

    end

    describe "GET show" do
      let(:provider) { providers.first }

      shared_examples "showable" do
        it_behaves_like "success"

        it "returns the provider" do
          expect(json['id']).to eql provider.id
        end
      end

      before do
        login
        get(:show, params: {id: Usr::Provider.first.id})
      end

      context "as super admin" do
        let(:login) { login_super_admin!}

        it_behaves_like "denied"
      end

      context "as admin" do
        context "accessible provider" do

          let(:login) do
            login_admin!
          end

          it_behaves_like "showable"
        end

        context "non accessible provider" do
          let(:login) do
            login_admin!
            provider.update practice: FactoryGirl.create(:practice)
          end

          it_behaves_like "denied"
        end
      end

      context "as reviewer"

      context "as provider" do
        let(:login) { login_provider! }

        it_behaves_like "denied"
      end
    end

    describe "POST create" do
      let(:new_user) { FactoryGirl.build(:user) }
      let(:user_atts) { new_user.as_json(methods: :password) }
      let(:license_atts) { [FactoryGirl.build(:license)].as_json }
      let(:payload) do
        {
          degree: 'phd',
          user_attributes: user_atts,
          licenses_attributes: license_atts
        }
      end

      before do
        login
        post(:create, params: {provider: payload})
      end

      context "as super admin" do
        let(:login) { login_super_admin!}

        it_behaves_like "denied"
      end

      context "as admin" do
        let(:login) do
          login_admin!
        end

        it_behaves_like "success"

        it "adds the provider to admins last facility" do
          expect(Usr::Provider.last.practice).to eql current_practice
        end

        context "missing password" do
          let(:user_atts) { new_user.as_json }

          it "responds with 422" do
            expect(response.status).to eql(422)
          end
        end

        context "missing license" do
          let(:license_atts) { [] }

          it "responds with 422" do
            expect(response.status).to eql(422)
          end
        end

        context "missing provider" do
          let(:payload) { {} }

          it "responds with 422" do
            expect(response.status).to eql(422)
          end

          it "responds with JSON msg" do
            expect(response.body).to eql({ provider: "is required"}.to_json)
          end
        end
      end

      context "as reviewer"

      context "as provider" do
        let(:login) { login_provider! }

        it_behaves_like "denied"
      end
    end

    describe "PATCH update" do
      shared_examples "updateable" do
        it_behaves_like "success"
        it "updates provider" do
          expect(base_provider.reload.user.first_name).to eql username
        end
      end

      let(:base_provider) { FactoryGirl.create(:provider, practice: current_practice) }
      let(:username) { "Ari" }
      let(:payload) do
        {
          user_attributes: { id: base_provider.user.id, first_name: username }
        }
      end

      before do
        login
        patch(:update, params: {id: base_provider.id, provider: payload})
      end

      context "as super admin" do
        let(:login) { login_super_admin! }

        it_behaves_like "denied"
      end

      context "as admin" do
        context "accessible provider" do
          let(:login) do
            login_admin!
          end

          it_behaves_like "updateable"
        end

        context "non-accessible provider" do
          let(:login) { login_admin!; base_provider.update practice: FactoryGirl.create(:practice) }

          it_behaves_like "denied"
        end
      end

      context "as reviewer"

      context "as provider" do
        let(:login) { login_provider! }

        it_behaves_like "denied"
      end
    end
  end
end

