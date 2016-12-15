FactoryGirl.define do
  factory :questionnaire do
    name 'string'
    service_id nil
    items_attributes Hash.new
  end
end
