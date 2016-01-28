require 'rails_helper'

RSpec.describe 'navigation bar', js: true do
  describe 'viewing the navigation bar' do
    context 'a user is signed in' do
      before :each do
        FactoryGirl.create(
	 :identity,
	 first_name: 'William',
	 last_name: 'Holt',
	 password: 'password',
	 password_confirmation: 'password',
	 ldap_uid: 'holtw@musc.edu',
	 email: 'holtw@musc.edu',
	 catalog_overlord: true,
	 approved: true,
	)
      end
      it 'should display the tabs' do
        visit new_identity_session_path
	click_link 'Outside Users Click Here'
	fill_in 'identity_ldap_uid', with: 'holtw@musc.edu'
	fill_in 'identity_password', with: 'password'
	click_button 'Sign In'
	expect(page).to have_link 'Dashboard'
	expect(page).to have_link 'Logout'
	expect(page).to have_content 'Logged in as holtw@musc.edu'
      end
    end
    context 'a user is not signed in' do
      it 'should not display the tabs' do
	expect(page).not_to have_link 'Dashboard'
	expect(page).not_to have_link 'Logout'
	expect(page).not_to have_content 'Logged in as holtw@musc.edu'
      end
    end
  end
end
