# The association with protocol must be created manually through the id's
# because of validations on protocol
FactoryGirl.define do

  factory :impact_area do
    name        { Faker::Lorem.word }
  end
end
