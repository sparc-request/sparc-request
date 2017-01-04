FactoryGirl.define do
  factory :submission do
    service_id nil
    identity_id nil
    questionnaire_id nil
    protocol_id nil
    line_item_id nil

    trait :with_responses do
      after(:create) do |submission|
        create_list(:questionnaire_response, submission.questionnaire.items.count, submission_id: submission.id)
        submission.questionnaire_responses.zip(submission.questionnaire.items).each do |response, item|
          response.item_id = item.id
        end
      end
    end

    factory :submission_with_responses, traits: [:with_responses]
  end
end
