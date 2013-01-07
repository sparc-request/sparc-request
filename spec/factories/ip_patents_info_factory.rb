FactoryGirl.define do

  factory :ip_patents_info do
    patent_number { Random.rand(20000).to_s }
    inventors     { Faker::Lorem.sentence(3) }
  end
end
