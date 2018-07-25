FactoryBot.define do
  factory :short_interactions, class: ShortInteraction do
    subject 'general_question'
    interaction_type 'email'
    duration_in_minutes '10'
    name 'Tester'
    email 'example@example.com'
    institution 'other'
    message 'this is a sample message'
  end
end