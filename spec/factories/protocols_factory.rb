FactoryGirl.define do

  factory :protocol do
    obisid                       { SecureRandom.hex(16) }
    next_ssr_id                  { Random.rand(10000) }
    short_title                  { Faker::Lorem.word }
    title                        { Faker::Lorem.sentence(3) }
    sponsor_name                 { Faker::Lorem.sentence(3) }
    brief_description            { Faker::Lorem.paragraph(2) }
    indirect_cost_rate           { Random.rand(1000) }
    study_phase                  { Faker::Lorem.word }
    udak_project_number          { Random.rand(1000).to_s }
    funding_rfa                  { Faker::Lorem.word }
    potential_funding_start_date { Time.now + 1.year }
    funding_start_date           { Time.now + 10.day }
    federal_grant_serial_number  { Random.rand(200000).to_s }
    federal_grant_title          { Faker::Lorem.sentence(2) }
    federal_grant_code_id        { Random.rand(1000).to_s }
    federal_non_phs_sponsor      { Faker::Lorem.word }
    federal_phs_sponsor          { Faker::Lorem.word }
    requester_id                 1

    trait :funded do
      funding_status "funded"
    end

    trait :pending do
      funding_status "pending"
    end

    trait :federal do
      funding_source           "federal"
      potential_funding_source "federal" 
    end
    
    ignore do
      project_role_count 1
      pi nil
    end

    # TODO: get this to work!
    # after(:build) do |protocol, evaluator|
    #   FactoryGirl.create_list(:project_role, evaluator.project_role_count, 
    #     protocol: protocol, identity: evaluator.pi)
    # end

    after(:build) do |protocol|
      protocol.build_ip_patents_info(FactoryGirl.attributes_for(:ip_patents_info))
      protocol.build_human_subjects_info(FactoryGirl.attributes_for(:human_subjects_info))
      protocol.build_investigational_products_info(FactoryGirl.attributes_for(:investigational_products_info))
      protocol.build_research_types_info(FactoryGirl.attributes_for(:research_types_info))
      protocol.build_vertebrate_animals_info(FactoryGirl.attributes_for(:vertebrate_animals_info)) 
    end


    factory :study do

      type { "Study" }
    end
  end
end
