FactoryGirl.define do

  factory :fulfillment do
    timeframe    { Faker::Lorem.word }
    notes        { Faker::Lorem.paragraph(4) }
    time         { "Right Now" }
    date         { Time.now }
  end
end
