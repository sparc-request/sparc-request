FactoryGirl.define do

  factory :service do
    id                  
    obisid              { SecureRandom.hex(16) }
    name                { Faker::Lorem.sentence(3) }
    abbreviation        { Faker::Lorem.words(1).first }
    description         { Faker::Lorem.paragraph(4) }
    is_available        { true }
    service_center_cost { Random.rand(100) }
    charge_code         { Faker::Lorem.words().first }
    revenue_code        { Faker::Lorem.words().first }

    pricing_maps        { [ FactoryGirl.create(:pricing_map) ] }
    
    trait :disabled do
      is_available false
    end 

    ignore do
      line_item_count 0
      pricing_map_count 0
      service_provider_count 0
      service_relation_count 0
    end

      after(:build) do |service, evaluator|
        FactoryGirl.create_list(:line_item, evaluator.line_item_count, 
          service: service)
        
        FactoryGirl.create_list(:pricing_map, evaluator.pricing_map_count, 
          service: service)

        FactoryGirl.create_list(:service_provider, evaluator.service_provider_count, 
          service: service)
    
        FactoryGirl.create_list(:service_relation, evaluator.service_relation_count, 
          service: service)
    end
  end
end