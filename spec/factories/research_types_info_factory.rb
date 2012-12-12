FactoryGirl.define do

  factory :research_types_info do
    id                       
    human_subjects           { false }
    vertebrate_animals       { false }
    investigational_products { false }
    ip_patents               { false }

    trait :has_human_subjects do
      human_subjects true
    end

    trait :has_vertebrate_animals do
      vertebrate_animals true
    end

    trait :has_investigational_products do
      investigational_products true
    end

    trait :has_ip_patents do
      ip_patents true
    end
  end
end