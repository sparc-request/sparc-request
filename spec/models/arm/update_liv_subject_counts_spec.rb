require 'rails_helper'

RSpec.describe Arm, type: :model do
  let!(:arm) { create(:arm, subject_count: 3) }
  let!(:liv) { create(:line_items_visit, line_item: li, arm: arm, subject_count: nil) }

  shared_examples_for 'change LineItemsVisit\'s subject_count' do
    it 'should set LineItemsVisit\'s subject_count to Arm\'s subject_count' do
      expect { arm.reload.update_liv_subject_counts }.to change { liv.reload.subject_count }.from(nil).to(3)
    end
  end

  describe '#update_liv_subject_counts' do
    context 'LineItemsVisit belongs to a ServiceRequest in \'draft\' status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'draft') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest in \'first_draft\' status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'first_draft') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest in nil status' do
      let!(:sr)  { create(:service_request_without_validations, status: nil) }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }
      let!(:liv) { create(:line_items_visit, line_item: li, arm: arm, subject_count: nil) }

      it_behaves_like 'change LineItemsVisit\'s subject_count'
    end

    context 'LineItemsVisit belongs to a ServiceRequest not in either \'draft\', \'first_draft\', nor nil status' do
      let!(:sr)  { create(:service_request_without_validations, status: 'sparc') }
      let!(:li)  { create(:line_item_with_service, service_request: sr) }

      it 'should set LineItemsVisit\'s subject_count to Arm\'s subject_count' do
        expect { arm.reload.update_liv_subject_counts }.not_to change { liv.reload.subject_count }
      end
    end
  end
end
