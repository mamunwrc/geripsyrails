FactoryGirl.define do
  factory :facility_contact, class: 'Adm::FacilityContact' do
    export_format :pdf
    export_type :full
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end
