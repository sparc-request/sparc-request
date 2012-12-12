FactoryGirl.define do
  rate_types = ["federal", "corporate", "member", "other"]


  factory :pricing_setup do
    id                         
    charge_master               { false }
    federal                     { 100 }
    corporate                   { 100 }
    other                       { 100 }
    member                      { 100 }
    college_rate_type           { rate_types.sample }
    federal_rate_type           { rate_types.sample }
    foundation_rate_type        { rate_types.sample }
    industry_rate_type          { rate_types.sample }
    investigator_rate_type      { rate_types.sample }
    internal_rate_type          { rate_types.sample }
    display_date                Date.parse('2000-01-01')
    effective_date              Date.parse('2000-01-01')

    trait :charge_master do
      charge_master true
    end
  end
end
