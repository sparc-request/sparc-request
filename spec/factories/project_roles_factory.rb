# Relationships with protocols must be created manually through the id's
# because of validations on protocol
FactoryGirl.define do

  factory :project_role do
    project_rights { Faker::Lorem.sentence(2) }
    role           'primary-pi'
    
  end
end
