require 'rails_helper'

RSpec.describe 'dashboard/documents/documents_table', type: :view do
  def render_documents_for(protocol, permission_to_edit=false)
    render 'dashboard/documents/documents_table',
      protocol: protocol,
      protocol_type: protocol.type,
      permission_to_edit: permission_to_edit
  end

  let_there_be_lane

  context 'User has permission to edit' do
    it 'should render documents_table' do
      protocol = build(:unarchived_study_without_validations, primary_pi: jug2)

      render_documents_for(protocol, true)

      expect(response).to have_selector('#document-new:not(.disabled)')
    end
  end

  context 'User does not have permission to edit' do
    it 'should not render documents_table' do
      protocol = build(:unarchived_study_without_validations, primary_pi: jug2)

      render_documents_for(protocol)

      expect(response).to have_selector('#document-new.disabled')
    end
  end
end
