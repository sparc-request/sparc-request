FactoryGirl.define do
  factory :submission do
    service_id nil
    identity_id nil
    questionnaire_id nil
    protocol_id nil
    line_item_id nil

    trait :with_responses do
      after(:create) do |submission|
        create(:questionnaire_response, submission_id: submission.id)
      end
    end

    factory :submission_with_responses, traits: [:with_responses]
  end
end
