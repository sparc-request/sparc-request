require 'rails_helper'

RSpec.feature "ProtocolForm", type: :feature, js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    org     = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1)
    @sr     = create(:service_request_without_validations, status: 'first_draft')
    ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'first_draft')
              create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
  end

  context 'Use Additional Funding Sources' do
    stub_config("use_additional_funding_sources", true)

    before :each do
      @protocol = create(:protocol_without_validations)
      visit edit_protocol_path(@protocol)
    end

    it 'should show additional funding sources container when the checkbox is checked' do
      find("[for='protocol_show_additional_funding_sources']").click
      # print protocol and its attributes
      "protocol: #{@protocol}"
      expect(page).to have_css('#additionalFundingSourcesContainer:not(.d-none)')
    end
  end
end
