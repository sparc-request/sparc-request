FactoryBot.define do
  factory :column_preference do
    identity { nil }
    table_id { "MyString" }
    column_preferences { "MyText" }
  end
end
