FactoryGirl.define do
  factory :ref_lookup, class: 'Ref::Lookup' do
    trait :encounters do
      group :encounters
    end

    trait :main do
      group :main
    end

    keyprefix "MYPREFIX"
    keyname "ISANAME"
    keyvalue "why, hello thar"
  end
end
