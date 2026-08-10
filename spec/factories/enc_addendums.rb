FactoryGirl.define do
  factory :enc_addendum, class: 'Enc::Addendum' do
    note "MyText"
    encounter_id 1
  end
end
