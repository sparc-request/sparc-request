FactoryGirl.define do
  
  factory :approval do
    id                 
    approval_date      { Time.now }
  end
end