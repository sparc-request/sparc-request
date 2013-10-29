FactoryGirl.define do
  factory :survey do
    title          { Faker::Lorem.word }
    description    { Faker::Lorem.word }
    access_code    { Faker::Lorem.word }
    survey_version { 0 }
  end
end
