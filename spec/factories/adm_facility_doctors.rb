FactoryGirl.define do
  factory :facility_doctor, class: 'Adm::FacilityDoctor' do
    name "MyString"
    association :facility
  end
end
