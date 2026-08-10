FactoryGirl.define do
  factory :group, class: 'Grp::Group' do
    name { Faker::RickAndMorty.location }
  end
end
