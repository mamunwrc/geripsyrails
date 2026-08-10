FactoryGirl.define do
  factory :grp_addendum, class: 'Grp::Addendum' do
    note "MyText"
    encounter_id 1
    user_id 1
  end
end
