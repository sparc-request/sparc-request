require 'rails_helper'

RSpec.describe 'dashboard/associated_users/_user_form', type: :view do
	let_there_be_lane
	let_there_be_j
	context 'User tries to edit associated users' do
		it 'should show the form' do
			project_role = build_stubbed(:project_role)
			protocol = build(:unarchived_study_without_validations, primary_pi: jug2)
			render "dashboard/associated_users/user_form", header_text: "Edit Authorized User", 
																										 identity: jug2,
																										 protocol: protocol,
																										 current_pi: jug2,
																										 project_role: project_role
			binding.pry
		end
	end
end