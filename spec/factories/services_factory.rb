FactoryGirl.define do

  factory :service do
    obisid              { SecureRandom.hex(16) }
    name                { Faker::Lorem.sentence(3) }
    abbreviation        { Faker::Lorem.words(1).first }
    description         { Faker::Lorem.paragraph(4) }
    is_available        { true }
    service_center_cost { Random.rand(100) }
    charge_code         { Faker::Lorem.words().first }
    revenue_code        { Faker::Lorem.words().first }
    #     pricing_maps        { [ FactoryGirl.create(:pricing_map) ] }
    
    trait :disabled do
      is_available false
    end 

    ignore do
      line_item_count 0
      pricing_map_count 1
      service_provider_count 0
      service_relation_count 0
    end

    before(:create) do |service, evaluator|
      evaluator.line_item_count.times do
        service.line_items.build(FactoryGirl.attributes_for(:line_item))
      end
      
      evaluator.pricing_map_count.times do
        service.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map))
      end

      evaluator.service_provider_count.times do
        service.service_providers.build(FactoryGirl.attributes_for(:service_provider))
      end

      evaluator.service_relation_count.times do
        service.service_relations.build(FactoryGirl.attributes_for(:service_relation))
      end
    end
  end
end
