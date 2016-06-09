require 'rails_helper'

RSpec.describe 'SubServiceRequest' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe '#notify_remote_around_update', delay: true do

    before { SubServiceRequest.skip_callback(:save, :after, :update_org_tree) }
    after { SubServiceRequest.set_callback(:save, :after, :update_org_tree) }
      
    context '.in_work_fulfillment changed' do

      it 'should create a RemoteServiceNotifierJob' do
        sub_service_request = build(:sub_service_request, in_work_fulfillment: false)

        sub_service_request.save validate: false
        sub_service_request.update_attribute :in_work_fulfillment, true

        expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
      end
    end

    context '.in_work_fulfillment not changed' do

      before do
        service = Service.first

        work_off

        service.update_attribute :name, 'Test'
      end

      it 'should create a RemoteServiceNotifierJob' do
        expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).not_to be
      end
    end
  end
end
