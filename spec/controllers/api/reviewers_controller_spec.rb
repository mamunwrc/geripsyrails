require 'rails_helper'

RSpec.describe Api::ReviewersController, type: :controller do

  describe 'DELETE /reviewers/:id' do
    before do
      login!
      delete :destroy, params: {id: reviewer.id}
    end

    shared_examples 'not deleted' do
      it 'still exists' do
        expect(Usr::Reviewer.find(reviewer.id)).to_not be_blank
      end
    end

    context 'as current practice admin' do
      let(:login!) { login_admin! }
      let(:admin) { Usr::Admin.last }
      let(:reviewer) { FactoryGirl.create(:usr_reviewer, practice: admin.practice) }

      it 'responds with OK' do
        expect(response).to be_ok
      end

      it 'deletes the reviewer' do
        expect{ Usr::Reviewer.find(reviewer.id) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'as current practice provider' do
      let(:login!) { login_provider! }
      let(:provider) { Usr::Provider.last }
      let(:reviewer) { FactoryGirl.create(:usr_reviewer, practice: provider.practice) }

      it 'responds with FORBIDDEN' do
        expect(response).to be_forbidden
      end

      it_behaves_like 'not deleted'
    end

    context 'as another practice admin' do
      let(:login!) { login_admin! }
      let(:reviewer) { FactoryGirl.create(:usr_reviewer) }

      it 'responds with NOT_FOUND' do
        expect(response).to be_not_found
      end

      it_behaves_like 'not deleted'
    end

  end

end

