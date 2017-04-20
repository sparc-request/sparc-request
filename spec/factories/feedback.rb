FactoryGirl.define do
  factory :feedback do
    letters Digest::SHA1.hexdigest(Time.now.usec.to_s)[0..16]
    name 'name'
    email 'email@email.com'
    date Date.today
    version '1'
    sparc_request_id '123'
  end
end
