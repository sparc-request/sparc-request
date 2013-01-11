FactoryGirl.define do

  factory :token do
    identity_id        { Random.rand(10000) }
    token              { Faker::Lorem.word }    
  end
end
