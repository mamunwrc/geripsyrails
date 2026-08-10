FactoryGirl.define do
  factory :enc_encounter_note, class: 'Enc::EncounterNote' do
    encounter_id 1
    patient_id 1
    provider_id 1
    note_type 1
    note_status "MyString"
    template_id 1
    note_section_type "MyString"
    note_section_seq 1
    note "MyText"
  end
end
