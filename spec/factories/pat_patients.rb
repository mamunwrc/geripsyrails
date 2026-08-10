FactoryGirl.define do
  factory :patient, class: 'Pat::Patient' do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    status :active

    association :facility
  end
end
