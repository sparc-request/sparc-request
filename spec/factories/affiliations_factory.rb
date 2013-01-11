# The association with protocol must be created manually through the id's
# due to validations on protocol
FactoryGirl.define do
  
  factory :affiliation do
    name                 { Faker::Lorem.word }
  end
end
