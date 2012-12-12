FactoryGirl.define do

  factory :past_status do
    id                     
    status                 { Faker::Lorem.word }
    date                   { Time.now }
  end
end