FactoryGirl.define do

  factory :service_level_component do
    service
    sequence(:component) { |n| "ServiceLevelComponent #{n}"}
  end
end
