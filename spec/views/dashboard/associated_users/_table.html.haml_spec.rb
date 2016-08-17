require 'rails_helper'

RSpec.describe 'dashboard/associated_users/_table', type: :view do
	let_there_be_lane
	let_there_be_j

	project_role = build_stubbed(:project_role)
	protocol = build(:unarchived_study_without_validations, id: 1, primary_pi: jug2, selected_for_epic: epic)