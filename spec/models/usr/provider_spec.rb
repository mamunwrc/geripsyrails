require 'rails_helper'

RSpec.describe Usr::Provider, type: :model do
  let(:provider) { create(:provider) }

  it 'adds practice_id to User' do
    expect(provider.user.practice_id).to_not be_nil
    expect(provider.user.practice_id).to eql(provider.practice_id)
  end
end
