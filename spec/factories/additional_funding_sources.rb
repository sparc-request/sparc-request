FactoryBot.define do
  factory :additional_funding_source do
    funding_source { "college" }
    sponsor_name { "MyString" }
    comments { "MyText" }
    federal_grant_code { "MyString" }
    federal_grant_serial_number { "MyString" }
    federal_grant_title { "MyString" }
    phs_sponsor { "MyString" }
    non_phs_sponsor { "MyString" }
    protocol_id { nil }
  end
end
