FactoryGirl.define do

  factory :submission_email do
    id             
    email           { Faker::Internet.email }    
  end
end