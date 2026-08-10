FactoryGirl.define do
  factory :admin, class: 'Usr::Admin' do
    after(:build) do |admin|
      admin.user = create(:user_admin)
    end
  end
end
