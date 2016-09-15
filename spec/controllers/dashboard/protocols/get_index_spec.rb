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

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #index' do
    context 'user has admin organizations' do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)
        allow(@logged_in_user).to receive(:authorized_admin_organizations).
          and_return([build_stubbed(:organization, name: 'MegaCorp')])

        paginated_protocols = double('protocols', page: [:protocols])
        filterrific = double('filterrific', find: paginated_protocols)
        allow(controller).to receive(:initialize_filterrific).
          and_return(filterrific)

        allow(ProtocolFilter).to receive(:latest_for_user).
          and_return("users filters")

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :index
      end

      it 'should use Filterrific to get protocols' do
        expect(controller).to have_received(:initialize_filterrific)
      end

      it "should assign @protocols to those returned by filterrific" do
        expect(assigns(:protocols)).to eq [:protocols]
      end

      it 'should assign @protocol_filters to the five most recent filters' do
        expect(ProtocolFilter).to have_received(:latest_for_user).
          with(@logged_in_user.id, 5)
        expect(assigns(:protocol_filters)).to eq("users filters")
      end

      it 'should assign @admin to false' do
        expect(assigns(:admin)).to eq(true)
      end

      it { is_expected.to render_template "dashboard/protocols/index" }
      it { is_expected.to respond_with :ok }
    end

    context 'user has no admin organizations' do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        allow(@logged_in_user).to receive(:authorized_admin_organizations).
          and_return([])

        protocol = build_stubbed(:protocol)
        build_stubbed(:project_role, identity: @logged_in_user, protocol: protocol)
        
        paginated_protocols = double('protocols', page: @logged_in_user.protocols)
        filterrific = double('filterrific', find: paginated_protocols)
        allow(controller).to receive(:initialize_filterrific).
          and_return(filterrific)

        allow(ProtocolFilter).to receive(:latest_for_user).
          and_return("users filters")

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :index
      end

      it 'should use Filterrific to get protocols' do
        expect(controller).to have_received(:initialize_filterrific)
      end

      it "should assign @protocols to those returned by filterrific" do
        expect(assigns(:protocols)).to eq @logged_in_user.protocols
      end

      it 'should assign @protocol_filters to the five most recent filters' do
        expect(ProtocolFilter).to have_received(:latest_for_user).
          with(@logged_in_user.id, 5)
        expect(assigns(:protocol_filters)).to eq("users filters")
      end

      it 'should assign @admin to false' do
        expect(assigns(:admin)).to eq(false)
      end

      it { is_expected.to render_template "dashboard/protocols/index" }
      it { is_expected.to respond_with :ok }
    end
  end
end
