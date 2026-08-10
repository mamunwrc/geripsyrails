FactoryGirl.define do
  factory :patient_note, class: 'Pat::Note' do
    sequence(:text) {|i| "Just a simple note ##{i}" }

    association :patient
    association :user
  end
end
