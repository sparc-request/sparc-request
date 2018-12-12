require 'rails_helper'

RSpec.describe 'Service Provider clicks Short Interaction', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config('use_short_interaction', true)

  before :each do
    institution    = create(:institution, name: "Institution")
    provider       = create(:provider, name: "Provider", parent: institution)
    create(:service_provider, identity_id: jug2.id, organization_id: provider.id)
    other_institution = ProfessionalOrganization.create(name: "Other Institution", org_type: "institution")
  end

  scenario 'and sees the short interaction modal' do
    visit root_path
    wait_for_javascript_to_finish

    click_link 'Short Interaction'
    wait_for_javascript_to_finish

    expect(page).to have_selector('#modal-title', text: 'Short Interaction', visible: true)
  end

  context 'and fills in the form and submits' do
    scenario 'and sees confirmation' do
      visit root_path
      wait_for_javascript_to_finish

      click_link 'Short Interaction'
      wait_for_javascript_to_finish

      fill_in 'short_interaction_duration_in_minutes', with: '10'
      fill_in 'short_interaction_name', with: 'Tester'
      fill_in 'short_interaction_email', with: 'test@abc.com'
      fill_in 'short_interaction_note', with: 'testing'
      select('Other Institution', from: 'short_interaction_institution')
      select('General Question', from: 'short_interaction_subject')
      select('Email', from: 'short_interaction_interaction_type')

      click_button 'Submit'
      wait_for_javascript_to_finish

      expect(ShortInteraction.count).to eq 1
    end
  end

end
