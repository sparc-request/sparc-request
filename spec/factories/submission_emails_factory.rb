FactoryGirl.define do

  factory :submission_email do
    email           { Faker::Internet.email }    
  end
end
