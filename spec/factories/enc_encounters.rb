FactoryGirl.define do
  factory :encounter, class: 'Enc::Encounter' do
    cpt_encounter_code "1"
    encounter_start "2016-03-04 12:54:08"
    encounter_end "2016-03-04 12:54:08"
    confidentiality false
    location "MyString"
    recorded_by 1
    recorded_on "2016-03-04 12:54:08"
    note "MyText"
    xml_data "MyText"

    association :patient

    factory :enc_90791 do
      cpt_encounter_code "90791"
    end
  end
end
