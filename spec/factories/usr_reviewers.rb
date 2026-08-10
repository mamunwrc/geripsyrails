FactoryGirl.define do
  factory :usr_reviewer, class: 'Usr::Reviewer' do
    association :practice 

    factory :reviewer do
      after(:build) do |reviewer|
        reviewer.user = create(:user_reviewer)
      end
    end
  end
end
