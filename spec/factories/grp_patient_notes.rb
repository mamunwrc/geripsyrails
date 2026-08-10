FactoryGirl.define do
  factory :grp_patient_note, class: 'Grp::PatientNote' do
    encounter_id 1
    body "MyString"
  end
end
