FactoryGirl.define do
  factory :license, class: 'Usr::License' do
    number { Faker::Number.number 9 }
    state { Faker::Address.state_abbr }
    expiration "2016-05-29 19:28:09"
  end
end
