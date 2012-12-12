FactoryGirl.define do

  factory :human_subjects_info do
    id                
    hr_number           { Random.rand(20000).to_s }
    pro_number          { Random.rand(20000).to_s }
    irb_of_record       { Faker::Lorem.word }
    submission_type     { Faker::Lorem.word }
    irb_approval_date   { Time.now }
    irb_expiration_date { Time.now + 15.day }
  end
end


