# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

RSpec.describe Dashboard::BaseController, type: :controller do
  let!(:logged_in_user) { create(:identity) }
  let!(:protocol)       { create(:protocol_without_validations) }

  before :each do
    log_in_dashboard_identity(obj: logged_in_user)
    controller.instance_variable_set(:@protocol, protocol)
  end

  describe '#protocol_authorizer_edit' do
    context 'user can edit protocol' do
      before :each do
        allow_any_instance_of(ProtocolAuthorizer).to receive(:can_edit?).and_return(true)
      end

      it 'should permit' do
        expect(controller).to_not receive(:authorization_error)

        controller.send(:protocol_authorizer_edit)
      end
    end

    context 'user is an admin' do
      before :each do
        allow_any_instance_of(ProtocolAuthorizer).to receive(:can_edit?).and_return(false)

        controller.instance_variable_set(:@admin, true)
      end

      it 'should permit' do
        expect(controller).to_not receive(:authorization_error)

        controller.send(:protocol_authorizer_edit)
      end
    end

    context 'user does not have permission' do
      before :each do
        allow_any_instance_of(ProtocolAuthorizer).to receive(:can_edit?).and_return(false)

        controller.instance_variable_set(:@admin, false)
      end

      it 'should not permit' do
        expect(controller).to receive(:authorization_error)

        controller.send(:protocol_authorizer_edit)
      end
    end
  end
end
