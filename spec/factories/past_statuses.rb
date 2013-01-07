FactoryGirl.define do

  factory :past_status do
    status                 { Faker::Lorem.word }
    date                   { Time.now }
  end
end
