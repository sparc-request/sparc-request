# Relationships with protocols must be created manually through the id's
# because of validations on protocol
FactoryGirl.define do

  factory :project_role do
    id            
    project_rights { Faker::Lorem.sentence(2) }
    role           'pi'
    
  end
end