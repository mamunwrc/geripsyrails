FactoryGirl.define do
  factory :provider, class: 'Usr::Provider' do
    provider_code { Faker::Number.number 3 }
    external_provider_code ""
    degree "pHd"
    position "Staff"
    speciality_license_number { Faker::Number.number 15 }
    medical_license_number { Faker::Crypto.md5[0..7] }
    tax_number { Faker::Number.number 14 }
    status "ACTIVE"
    dea_number { Faker::Crypto.md5[0..9] }
    dea_extension { Faker::Crypto.md5[0..11] }
    upin { Faker::Crypto.md5[0..23] }
    npi { Faker::Number.number 10 }
    medicare_id { Faker::Number.number 10 }
    medicaid_id { Faker::Number.number 10 }
    hmo_id { Faker::Crypto.md5[0..11] }
    bank_account_number { Faker::Number.number 12 }
    bank_routing_number { Faker::Number.number 12 }
    can_prescribe true
    xml_data ""

    association :practice

    after(:build) do |provider|
      provider.user = create(:user_provider)
      provider.licenses << build(:license, provider: provider)
    end
  end
end
