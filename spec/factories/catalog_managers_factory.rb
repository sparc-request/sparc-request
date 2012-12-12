FactoryGirl.define do

  factory :catalog_manager do
    id                 
    edit_historic_data { false } 
    
    trait :can_edit_historic_data do
      edit_historic_data true
    end
  end
end