require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#update_visit_group_window_before' do
    let(:arm) { create(:arm, visit_count: 1, line_item_count:1) }

    shared_examples 'window_before invalid' do
      it 'should add a message to errors[:invalid_window_before]' do
        expect(arm.errors[:invalid_window_before]).not_to be_empty
      end

      it 'should not set specfied VisitGroup\'s window_before' do
        expect(arm.reload.visit_groups[0].window_before).to eq nil
      end
    end

    shared_examples 'window_before valid' do
      it 'should not add messages to errors[:invalid_window_before]' do
        expect(arm.errors[:invalid_window_before]).to be_empty
      end
    end

    context 'window_before not a valid integer' do
      before(:each) { arm.update_visit_group_window_before 'sparc', 0 }

      it_behaves_like 'window_before invalid'
    end

    context 'window_before negative' do
      before(:each) { arm.update_visit_group_window_before '-1', 0 }

      it_behaves_like 'window_before invalid'
    end

    context 'window_before == 0' do
      before(:each) { arm.update_visit_group_window_before '0', 0 }

      it 'should set VisitGroup\'s window_before to 0' do
        expect(arm.reload.visit_groups[0].window_before).to eq 0
      end

      it_behaves_like 'window_before valid'
    end

    context 'window_before > 0' do
      before(:each) { arm.update_visit_group_window_before '1', 0 }

      it 'should set VisitGroup\'s window_before' do
        expect(arm.reload.visit_groups[0].window_before).to eq 1
      end

      it_behaves_like 'window_before valid'
    end
  end
end
