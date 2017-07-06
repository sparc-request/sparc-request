# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'RemoteServiceNotifierJob', type: :model do

  before { @object = create(:service_without_callback_notify_remote_service_after_create) }

  describe 'self#enqueue', delay: true do

    before { RemoteServiceNotifierJob.enqueue(@object.id, @object.class.name, 'create') }

    it 'should create a DelayedJob' do
      expect(Delayed::Job.where("handler LIKE '%RemoteServiceNotifierJob%'").one?).to be
    end
  end

  describe '#perform' do

    before { @job = RemoteServiceNotifierJob.new(@object.id, @object.class.name, 'create') }

    context 'remote service available' do

      it 'should send a POST request to the remote service' do
        @job.perform

        expect(a_request(:post, /#{REMOTE_SERVICE_NOTIFIER_HOST}/)).to have_been_made.once
      end
    end

    context 'remote service unavailable', remote_service: :unavailable do

      it 'should raise an exception' do
        expect{ @job.perform }.to raise_error RemoteServiceNotifierJob::RemoteServiceNotifierError
      end
    end
  end
end
