FactoryGirl.define do

  factory :excluded_funding_source do
    id
    funding_source { Faker::Lorem.word } 
  end
end