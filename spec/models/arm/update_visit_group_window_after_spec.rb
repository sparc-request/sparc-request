require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#update_visit_group_window_after' do
    let(:arm) { create(:arm, visit_count: 1, line_item_count:1) }

    shared_examples 'window_after invalid' do
      it 'should add a message to errors[:invalid_window_after]' do
        expect(arm.errors[:invalid_window_after]).not_to be_empty
      end

      it 'should not set specfied VisitGroup\'s window_after' do
        expect(arm.reload.visit_groups[0].window_after).to eq nil
      end
    end

    shared_examples 'window_after valid' do
      it 'should not add messages to errors[:invalid_window_after]' do
        expect(arm.errors[:invalid_window_after]).to be_empty
      end
    end

    context 'window_after not a valid integer' do
      before(:each) { arm.update_visit_group_window_after 'sparc', 0 }

      it_behaves_like 'window_after invalid'
    end

    context 'window_after negative' do
      before(:each) { arm.update_visit_group_window_after '-1', 0 }

      it_behaves_like 'window_after invalid'
    end

    context 'window_after == 0' do
      before(:each) { arm.update_visit_group_window_after '0', 0 }

      it 'should set VisitGroup\'s window_after to 0' do
        expect(arm.reload.visit_groups[0].window_after).to eq 0
      end

      it_behaves_like 'window_after valid'
    end

    context 'window_after > 0' do
      before(:each) { arm.update_visit_group_window_after '1', 0 }

      it 'should set VisitGroup\'s window_after' do
        expect(arm.reload.visit_groups[0].window_after).to eq 1
      end

      it_behaves_like 'window_after valid'
    end
  end
end
