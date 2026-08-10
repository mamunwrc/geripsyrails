FactoryGirl.define do
  factory :remit, class: 'Adm::Remit' do
  end
  factory :remit_with_data, class: 'Adm::Remit' do
    status 'posted'
    batch { Faker::Number.number(10) }
    content { Faker::Lorem.paragraph }
    posted_on { Faker::Date.backward(1000) }
  end
end
