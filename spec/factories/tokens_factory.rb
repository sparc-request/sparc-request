FactoryGirl.define do

  factory :token do
    id                
    identity_id        { Random.rand(10000) }
    token              { Faker::Lorem.word }    
  end
end