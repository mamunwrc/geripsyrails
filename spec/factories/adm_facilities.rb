FactoryGirl.define do
  factory :facility, class: 'Adm::Facility' do
    name { Faker::Company.name[0..31] }
    address1  { Faker::Address.street_address }
    address2  { Faker::Address.secondary_address }
    city  { Faker::Address.city }
    state "NY"
    zip  { Faker::Address.zip }
    home_phone { Faker::PhoneNumber.phone_number }
    work_phone { Faker::PhoneNumber.phone_number }
    npi { Faker::Number.number(10) }

    association :practice
  end
end
