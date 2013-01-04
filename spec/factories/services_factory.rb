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

    # This line was removed, because it causes duplicate pricing maps to
    # be created (see pricing_map_count, below).
    # pricing_maps        { [ FactoryGirl.create(:pricing_map) ] }
    
    trait :disabled do
      is_available false
    end 

    ignore do
      line_item_count 0
      pricing_map_count 1
      service_provider_count 0
      service_relation_count 0
    end

    # Note that this is a before(:create) block.  This is necessary to
    # ensure that pricing maps are added to the service _before_ it is
    # created (otherwise validation will fail).
    before(:create) do |service, evaluator|

      # There are two ways which we add pricing maps to a newly created
      # service in a test:
      #
      #   1) pricing_map = FactoryGirl.create(:pricing_map, ...)
      #      service = FactoryGirl.create(:service, pricing_maps = [ pricing_map ], ... )
      #
      #   2) service = FactoryGirl.create(:service, pricing_map_count = 1, ...)
      #
      # This will ensure that if pricing_maps is specified, we won't
      # create any additional pricing maps.
      line_item_count = evaluator.line_items.count > 0 ? 0 : evaluator.line_item_count
      pricing_map_count = evaluator.pricing_maps.count > 0 ? 0 : evaluator.pricing_map_count
      service_provider_count = evaluator.service_providers.count > 0 ? 0 : evaluator.service_provider_count
      service_relation_count = evaluator.service_relations.count > 0 ? 0 : evaluator.service_relation_count

      # We were using FactoryGirl.create_list, but this will not
      # associate the new pricing maps with the service.

      line_item_count.times do
        service.line_items.build(FactoryGirl.attributes_for(:line_item))
      end
      
      pricing_map_count.times do
        service.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map))
      end

      service_provider_count.times do
        service.service_providers.build(FactoryGirl.attributes_for(:service_provider))
      end

      service_relation_count.times do
        service.service_relations.build(FactoryGirl.attributes_for(:service_relation))
      end
    end
  end
end
