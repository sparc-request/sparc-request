FactoryGirl.define do

  factory :visit do
    quantity                   { 15 }
    billing                    { Faker::Lorem.word }
    research_billing_qty       { 5 }
    insurance_billing_qty      { 5 }
    effort_billing_qty         { 5 }
    name                       { "" }
  end
end
