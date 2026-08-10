require 'rails_helper'

RSpec.describe Api::RefIcdsController, type: :controller do
  describe "GET index" do
    context "when logged in" do
      before do
        login_user!
        icd
        get :index
      end

      let(:icd) { create(:ref_icd) }

      it "responds successfully" do
        expect(response.status).to eql(200)
      end

      it "responds with ref_icds" do
        expect(JSON.parse(response.body).first).to include({'keyname' => icd.icd, 'keyvalue' => icd.to_s})
      end
    end
  end
end
