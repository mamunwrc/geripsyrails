FactoryGirl.define do
  factory :practice, class: 'Adm::Practice' do
    name { Faker::Company.name[0..31] }
    practice_type :solo
    address1  { Faker::Address.street_address }
    address2  { Faker::Address.secondary_address }
    city  { Faker::Address.city }
    state "NY"
    zip  { Faker::Address.zip }
  end
end
