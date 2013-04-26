# The association with protocol must be set manually throught the id's
# due to validations on protocol
FactoryGirl.define do
  factory :service_request do
    protocol_id          { Random.rand(10000) }
    obisid               { SecureRandom.hex(16) }
    status               { Faker::Lorem.sentence(3) }
    service_requester_id { Random.rand(1000) }
    notes                { Faker::Lorem.sentences(2) }
    approved             { false }


    trait :approved do
      approved true
    end

    ignore do
      sub_service_count 0
      line_item_count 0
      subsidy_count 0
      charge_count 0
      token_count 0
      approval_count 0
    end

    after(:build) do |service_request, evaluator|

      FactoryGirl.create_list(:sub_service_request, evaluator.sub_service_count, 
        service_request: service_request)

      FactoryGirl.create_list(:line_item, evaluator.line_item_count, 
        service_request: service_request)

      FactoryGirl.create_list(:subsidy, evaluator.subsidy_count,
        service_request: service_request)

      FactoryGirl.create_list(:charge, evaluator.charge_count,
        service_request: service_request)

      FactoryGirl.create_list(:token, evaluator.token_count,
        service_request: service_request)

      FactoryGirl.create_list(:approval, evaluator.approval_count,
        service_request: service_request)
    end
  end
end
