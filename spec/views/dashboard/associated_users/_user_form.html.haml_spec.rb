require 'rails_helper'

RSpec.describe 'dashboard/associated_users/_user_form', type: :view do

  let_there_be_lane

  def render_user_form(epic = false)
    protocol = build(:unarchived_study_without_validations, id: 1, primary_pi: jug2, selected_for_epic: epic)
    project_role = build(:project_role, id: 1, protocol_id: protocol.id, identity_id: jug2.id, role: 'consultant', epic_access: 0)
    stub_const("USE_EPIC", epic)
    render "dashboard/associated_users/user_form", header_text: "Edit Authorized User",
                                                   identity: jug2,
                                                   protocol: protocol,
                                                   current_pi: jug2,
                                                   project_role: project_role
  end

  context 'When the user views the associated users form' do

    it 'should show the correct header and labels' do
      render_user_form
      expect(response).to have_selector('h4', text: "Edit Authorized User")
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:credentials])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:institution])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:college])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:department])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:phone])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:role])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:rights][:header])
      expect(response).to have_selector('label', text: t(:dashboard)[:authorized_users][:college])
    end

    it 'should show the correct buttons' do
      render_user_form
      expect(response).to have_selector('button', text: t(:actions)[:close])
      expect(response).to have_selector('button', text: t(:actions)[:save])
      expect(response).to have_selector('button.close')
      expect(response).to have_selector('button', count: 3)
    end

    it 'should show the correct form fields when not using epic and protocol is not selected for epic' do
      render_user_form
      expect(response).to have_selector('.form-control', count: 10)
      expect(response).to have_selector('.radio', 4)
      expect(response).to have_selector('.checkbox-inline', count: 0)
      expect(response).not_to have_selector('label', text: 'No')
      expect(response).not_to have_selector('label', text: 'Yes')
    end

    it 'should show the correct form fields when using epic and protocol is selected for epic' do
      render_user_form true
      expect(response).to have_selector('label', text: 'No')
      expect(response).to have_selector('label', text: 'Yes')
      expect(response).to have_selector('.checkbox-inline', count: 2)
    end
  end
end
