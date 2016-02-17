require 'rails_helper'

RSpec.describe 'send message to sparc team' do

  scenario 'a user sends a message', js: true do
    user = create(:identity, approved: true)
    visit new_identity_session_path
    click_link 'Outside Users Click Here'
    fill_in 'identity_ldap_uid', with: user.ldap_uid
    fill_in 'identity_password', with: user.password
    click_button 'Sign In'

    click_link 'Contact Us'
    fill_in 'contact_form_subject', with: 'subject'
    fill_in 'contact_form_email', with: 'example@example.com'
    fill_in 'contact_form_message', with: 'message'
    click_button 'Send Message'

    expect(page).to have_content 'Message sent'
  end
end