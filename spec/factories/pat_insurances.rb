FactoryGirl.define do
  factory :insurance, class: 'Pat::Insurance' do
    name Faker::Company.name
    sequence(:hp_id_code) {|i| i.succ }
  end
end
