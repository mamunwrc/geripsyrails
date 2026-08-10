FactoryGirl.define do
  factory :enc_encounter_assessment, class: 'Enc::EncounterAssessment' do
    encounter_id 1
    sno_code "MyString"
    icd_code "MyString"
    description "MyString"
    assessment_status "MyString"
    category "MyString"
    comment "MyText"
    provider_id 1
    recorded_by 1
    recorded_on "2016-03-04 12:48:11"
    category_rank 1
    assessment_rank 1
    xml_data "MyText"
  end
end
