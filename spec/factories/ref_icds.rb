FactoryGirl.define do
  factory :ref_icd, class: 'Ref::Icd' do
    icd { Faker::Number.decimal(2,3) }
    description { Faker::Lorem.sentence }
  end
end
