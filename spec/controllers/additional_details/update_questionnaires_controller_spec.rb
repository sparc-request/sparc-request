require 'rails_helper'

RSpec.describe AdditionalDetails::UpdateQuestionnairesController do
  describe '#update' do
    context 'successfully' do
      it 'should update a questionnaires status to active' do
        service = create(:service)
        questionnaire = create(:questionnaire, service: service, active: false)

        xhr :patch, :update, service_id: service, id: questionnaire

        questionnaire.reload

        expect(questionnaire.active?).to eq true
      end

    end
    context 'unsuccessfully' do
      it 'should update a questionnaires status to active' do
        service = create(:service)
        questionnaire = create(:questionnaire, service: service, active: true)

        xhr :patch, :update, service_id: service, id: questionnaire

        questionnaire.reload

        expect(questionnaire.active?).to eq false
      end
    end
  end
end
