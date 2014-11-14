require 'spec_helper'

RSpec.describe 'RemoteServiceNotifierJob', type: :model do

  before { @object = FactoryGirl.create(:service_without_callback_notify_remote_service_after_create) }

  describe 'self#enqueue', delay: true do

    before { RemoteServiceNotifierJob.enqueue(@object, 'create') }

    it 'should create a DelayedJob' do
      expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
    end
  end

  describe '#perform' do

    before { @job = RemoteServiceNotifierJob.new(@object, 'create') }

    context 'remote service available' do

      it 'should send a POST request to the remote service' do
        @job.perform

        expect(a_request(:post, /#{REMOTE_SERVICE_NOTIFIER_HOST}/)).to have_been_made.once
      end
    end

    context 'remote service unavailable', remote_service: :unavailable do

      it 'should raise an exception' do
        expect{ @job.perform }.to raise_exception
      end
    end
  end
end
