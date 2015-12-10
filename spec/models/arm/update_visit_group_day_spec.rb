require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#update_visit_group_day' do
    it 'should update VisitGroup\'s day' do
      arm.update_visit_group_day '4', 2
      expect(arm.reload.visit_groups[2].day).to eq 4
    end

    shared_examples 'should not set day' do
      it 'shouldn\'t change VisitGroup\'s day' do
        expect(arm.reload.visit_groups[1].day).to eq 1
      end
    end

    shared_examples 'no day validations' do
      it 'should not validate day' do
        expect(arm.errors[:invalid_day]).to be_empty
        expect(arm.errors[:out_of_order]).to be_empty
      end
    end

    let(:arm) { create(:arm, visit_count: 3, line_item_count: 1) }

    context 'USE_EPIC == true and portal == "true"' do
      before(:each) { stub_const("USE_EPIC", true) }

      context 'day smaller than preceding VisitGroup' do
        before(:each) { arm.update_visit_group_day '-1', 1, 'true' }

        it_behaves_like 'should not set day'

        it 'should add a message to errors[:out_of_order]' do
          expect(arm.errors[:out_of_order]).not_to be_empty
        end
      end

      context 'day greater than following VisitGroup' do
        before(:each) { arm.update_visit_group_day '4', 1, 'true' }

        it_behaves_like 'should not set day'

        it 'should add a message to errors[:out_of_order]' do
          expect(arm.errors[:out_of_order]).not_to be_empty
        end
      end

      context 'day not a valid integer' do
        before(:each) { arm.update_visit_group_day 'sparc', 1, 'true' }

        it_behaves_like 'should not set day'

        it 'should add a message to errors[:invalid_day]' do
          expect(arm.errors[:invalid_day]).not_to be_empty
        end
      end

      context 'day valid' do
        before(:each) { arm.update_visit_group_day '4', 2, 'true' }

        it 'should update VisitGroup\'s day' do
          expect(arm.reload.visit_groups[2].day).to eq 4
        end

        it 'shouldn\'t set errors[:invalid_day]' do
          expect(arm.errors[:invalid_day]).to be_empty
        end
      end
    end

    context 'USE_EPIC == false and portal == \'true\'' do
      before(:each) do
        stub_const("USE_EPIC", false)
        arm.update_visit_group_day 'sparc', 0, 'true'
      end

      it_behaves_like 'no day validations'
    end

    context 'USE_EPIC == true and portal == \'false\'' do
      before(:each) do
        stub_const("USE_EPIC", true)
        arm.update_visit_group_day 'sparc', 0, 'false'
      end

      it_behaves_like 'no day validations'
    end

    context 'USE_EPIC == false and portal == \'false\'' do
      before(:each) do
        stub_const("USE_EPIC", false)
        arm.update_visit_group_day 'sparc', 0, 'false'
      end

      it_behaves_like 'no day validations'
    end
  end
end
