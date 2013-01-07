# The association with protocol must be set manually through the id's
# due to validations on protocol
FactoryGirl.define do

  factory :study_type do
    name        { Faker::Lorem.word }
  end
end
