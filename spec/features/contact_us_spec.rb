require 'rails_helper'

RSpec.describe 'send message to sparc team' do

  scenario 'a user sends a message', js: true do
    visit root_path
    click_link 'Contact Us'
    fill_in 'contact_form_subject', with: 'subject'
    fill_in 'contact_form_email', with: 'example@example.com'
    fill_in 'contact_form_message', with: 'message'
    click_button 'Send Message'
    expect(page).to have_content 'Message sent'
  end
end