require 'rails_helper'

RSpec.describe 'User should see service questionnaire index', js: true do
  let_there_be_lane
  scenario 'successfully' do
    service = create(:service)
    questionnaire = create(:questionnaire,
                           name: 'Awesome Questionnaire',
                           service: service)
    create(:item, questionnaire: questionnaire)

    visit service_additional_details_questionnaires_path(service)

    expect(page).to have_css 'tr td', text: questionnaire.name
  end
end
