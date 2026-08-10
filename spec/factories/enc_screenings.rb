FactoryGirl.define do
  factory :enc_screening, class: 'Enc::Screening' do
    axes ""
    screening_type 1
    encounter_id 1
  end
end
