FactoryGirl.define do
  factory :contact_form, class: ContactForm do
    subject 'SPARC-Request'
    email 'example@example.com'
    message 'this is a sample message'
  end
end