require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  describe 'PATCH update' do
    let(:group) { create(:group, practice: current_practice) }
    let(:new_name) { Faker::RickAndMorty.location }
    let(:new_email) { Faker::Internet.email }
    let(:payload) {
      {
        params: {
          id: group.id,
          group: {
            name: new_name,
            contact_email: new_email,
            contact_active: true
          }
        }
      }
    }

    let(:parsed_resp) { JSON.parse(response.body) }

    before do
      setup!
      patch :update, payload
    end

    context 'when admin' do
      let(:setup!) { login_admin! }
      it 'can update name' do
        expect(parsed_resp['name']).to eql(new_name)
      end

      it 'can update contact_email' do
        expect(parsed_resp['contact_email']).to eql(new_email)
      end

      it 'can update contact_active' do
        expect(parsed_resp['contact_active']).to eql(true)
      end
    end

    context 'when provider' do
      let(:setup!) do
        login_provider!
        group.providers << current_user.meta
      end

      it 'can update name' do
        expect(parsed_resp['name']).to eql(new_name)
      end

      it 'cannot update contact_email' do
        expect(parsed_resp['contact_email']).to be_nil
        expect(group.reload.contact_email).to_not eql(new_email)
      end

      it 'cannot update contact_active' do
        expect(parsed_resp['contact_active']).to be_nil
        expect(group.reload.contact_active).to_not be
      end
    end
  end
end
