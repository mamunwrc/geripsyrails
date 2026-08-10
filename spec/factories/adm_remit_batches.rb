FactoryGirl.define do
  factory :remit_batch, class: 'Adm::RemitBatch' do
    batch_date { Faker::Date.backward(100) }
    payload({files: []})
    ip { Faker::Internet.ip_v4_address }
    practice_id 1
    token "MyString"
  end
end
