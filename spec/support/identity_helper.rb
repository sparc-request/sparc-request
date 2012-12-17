module IdentityHelper
  def log_in(identity, password)
    visit catalog_manager_root_path
    fill_in 'identity_ldap_uid', :with => identity
    fill_in 'identity_password',  :with => password
    click_button 'Sign in'
  end
  
end