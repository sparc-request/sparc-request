require 'rails_helper'

RSpec.describe 'dashboard/associated_users/_select_user_form', type: :view do

  let_there_be_lane

  def render_user_search_form
    protocol = build(:unarchived_study_without_validations, id: 1, primary_pi: jug2)
    render "dashboard/associated_users/select_user_form", header_text: "Add Authorized User",
                                                          protocol: protocol
  end

  context 'When the user tries to add another authorized user to the project' do

    it 'should show the search bar and the correct labels' do
      render_user_search_form
      expect(response).to have_content('Add Authorized User')
      expect(response).to have_content('Select User:')
      expect(response).to have_selector('input')
      expect(response).to have_selector('button', text: 'Close')
    end
  end
end
