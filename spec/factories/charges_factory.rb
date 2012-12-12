FactoryGirl.define do

  factory :charge do
    id                 
    charge_amount      { Random.rand(1000) }
  end
end