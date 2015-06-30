require 'spec_helper'

RSpec.describe ProjectRole, type: :model do

  describe 'callbacks' do

    before do
      protocol = FactoryGirl.build(:protocol)
      protocol.save validate: false

      service_request = FactoryGirl.build(:service_request, protocol: protocol)
      service_request.save validate: false
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)

      sub_service_request = FactoryGirl.build(:sub_service_request,
                                              service_request: service_request,
                                              in_work_fulfillment: true)
      sub_service_request.save validate: false

      work_off

      @project_role = FactoryGirl.create(:project_role, protocol: protocol)
    end

    describe '#notify_remote_after_create' do

      it 'should create a RemoteServiceNotifierJob Delayed::Job' do
        expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
      end
    end

    describe '#notify_remote_around_update' do

      it 'should create a RemoteServiceNotifierJob Delayed::Job' do
        work_off

        @project_role.update_attributes role_other: 'role_other'

        expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
      end
    end

    describe '#notify_remote_after_destroy' do

      it 'should create a RemoteServiceNotifierJob Delayed::Job' do
        work_off

        @project_role.destroy

        expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
      end
    end
  end
end
