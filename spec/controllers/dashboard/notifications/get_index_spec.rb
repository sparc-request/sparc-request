# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe Dashboard::NotificationsController do
  describe "GET #index" do
    before :each do
      @logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: @logged_in_user)
    end

    context 'inbox' do
      before :each do
        allow(Notification).to receive(:in_inbox_of).
          with(@logged_in_user.id, anything).
          and_return(Notification.none)
      end

      it 'should return received messages' do
        expect(Notification).to receive(:in_inbox_of)

        get :index, params: { table: "inbox", sub_service_request_id: "1234", format: :json }
      end
    end

    context 'sent' do
      before :each do
        allow(Notification).to receive(:in_sent_of).
          with(@logged_in_user.id, anything).
          and_return(Notification.none)
      end

      it 'should return sent messages' do
        expect(Notification).to receive(:in_sent_of)

        get :index, params: { table: "not-inbox", sub_service_request_id: "", format: :json }
      end
    end
  end
end
