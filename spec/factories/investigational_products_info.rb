FactoryGirl.define do

  factory :investigational_products_info do
    ind_number  { Random.rand(20000).to_s }
    ind_on_hold { false }
    ide_number  { Random.rand(20000).to_s }

    trait :ind_on_hold do
      ind_on_hold true
    end
  end
end
