require 'rails_helper'

RSpec.describe Api::RefLookupsController, :type => :controller do
  describe "GET index" do
    login_user
    let(:res_json) { JSON.parse(response.body) }
    let!(:main_lookup) { FactoryGirl.create(:ref_lookup, :main)}
    let!(:enc_lookup) { FactoryGirl.create(:ref_lookup, :encounters)}
    let(:lookup_type) { nil }
    let(:ref_group) { res_json[lookup_type.keyprefix].first['group'] }

    before do
      get :index, params: {group: group}
    end

    describe "no group provided" do
      let(:group) { nil }
      let(:lookup_type) { main_lookup }

      it "responds with main lookups" do
        expect(ref_group).to eql('main')
      end
    end

    describe "existing group provided" do
      let(:group) { 'encounters' }
      let(:lookup_type) { enc_lookup }

      it "responds with correct lookups" do
        expect(ref_group).to eql('encounters')
      end
    end

    describe "invalid group provided" do
      let(:group) { 'fakegroup' }

      it "responds with nothing" do
        expect(res_json).to be_blank
      end
    end
  end

end
