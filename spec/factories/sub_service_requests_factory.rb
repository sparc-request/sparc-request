FactoryGirl.define do
  factory :sub_service_request do
    id                
    owner_id           { Random.rand(1000) }
    ssr_id             { Faker::Lorem.word }
    status             { Faker::Lorem.sentence(5) }
    
    ignore do
      line_item_count 0
      past_status_count 0
    end

    after(:build) do |sub_service_request, evaluator|      
      FactoryGirl.create_list(:line_item, evaluator.line_item_count, 
        sub_service_request: sub_service_request)
    
      FactoryGirl.create_list(:past_status, evaluator.past_status_count, 
        sub_service_request: sub_service_request)
    end
  end
end