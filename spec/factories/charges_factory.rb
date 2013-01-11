FactoryGirl.define do

  factory :charge do
    charge_amount      { Random.rand(1000) }
  end
end
