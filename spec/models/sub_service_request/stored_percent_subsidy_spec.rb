require 'rails_helper'

RSpec.describe SubServiceRequest, type: :model do

  describe '.approved_percent_subsidy' do

    before { SubServiceRequest.skip_callback(:save, :after, :update_org_tree) }
    after { SubServiceRequest.set_callback(:save, :after, :update_org_tree) }
      
    context 'subsidy present' do

      it 'should return the Subsidy.approved_percent_subsidy' do
        sub_service_request = create(:sub_service_request)
        subsidy             = create(:subsidy,
                                      sub_service_request: sub_service_request,
                                      stored_percent_subsidy: 1.1)

        expect(sub_service_request.approved_percent_subsidy).to eq(1.1)
      end
    end

    context 'subsidy not present' do

      it 'should return: 0' do
        sub_service_request = create(:sub_service_request)

        expect(sub_service_request.approved_percent_subsidy).to eq(0)
      end
    end
  end
end
