FactoryGirl.define do
  factory :payment do
    amount_invoiced 100.0
    amount_received 100.0
    date_submitted  Date.parse('2000-01-01')
    date_received   Date.parse('2000-01-01')
  end
end
