FactoryGirl.define do

  factory :vertebrate_animals_info do
    iacuc_number          { Random.rand(20000).to_s }
    iacuc_approval_date   { Time.now }
    iacuc_expiration_date { Time.now + 15.day }
  end
end
