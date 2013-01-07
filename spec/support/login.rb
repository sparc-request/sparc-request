def sign_in uid="jug2", password="p4ssword"
  fill_in "identity_ldap_uid", :with => uid
  fill_in "identity_password", :with => password
  click_button "Sign in"
end

include Warden::Test::Helpers

def fake_login_for_each_test(uid='jug2')
  before :each do
    Warden.test_mode!
    identity = Identity.find_by_ldap_uid(uid)
    login_as(identity)
  end

  after :each do
    Warden.test_reset!
  end
end

