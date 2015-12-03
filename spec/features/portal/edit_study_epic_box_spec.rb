require 'rails_helper'

RSpec.describe "edit study epic box", js: true do
	let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:numerical_day) { Date.today.strftime("%d").gsub(/^0/,'') }

  before :each do
    visit edit_portal_protocol_path service_request.protocol.id
    wait_for_javascript_to_finish
  end

  scenario "Study type equals 0" do 
  	find('#study_selected_for_epic_true').click
  	save_and_open_screenshot

  	select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
  	# find("#study_type_answer_certificate_of_conf_answer").set(true)
   #  find("#study_type_answer_certificate_of_conf_answer").trigger('change')

   #  find('#study_type_answer_higher_level_of_privacy_answer').set(true)
   #  find('#study_type_answer_higher_level_of_privacy_answer').trigger('change')

  end
end