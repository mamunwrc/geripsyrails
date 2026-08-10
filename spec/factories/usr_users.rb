FactoryGirl.define do
  factory :user, class: 'Usr::User' do
    last_name { Faker::Name.first_name }
    first_name { Faker::Name.last_name }
    middle_name ""
    title ""
    suffix ""
    initials ""
    ssn ""
    dob "2016-03-30 16:39:00"
    gender ""
    position "MyString"
    address1 ""
    address2 ""
    city ""
    state ""
    zip ""
    home_phone ""
    work_phone ""
    fax ""
    cell ""
    pager ""
    alternate_phone ""
    email { Faker::Internet.email }
    authorization_token ""
    login_name ""
    xml_data "MyText"
    password "password123"

    factory :super_admin do
      after(:create) {|u| u.add_role :super_admin}
    end

    factory :user_admin do
      after(:create) {|u| u.add_role :admin}
    end

    factory :user_reviewer do
      after(:create) {|u| u.add_role :reviewer}
    end

    factory :user_provider do
      after(:create) {|u| u.add_role :provider}
    end
  end
end

