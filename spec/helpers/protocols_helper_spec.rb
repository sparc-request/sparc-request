# Copyright © 2011-2020 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe ProtocolsHelper, type: :helper do
  let!(:protocol) { create(:study_federally_funded, primary_pi: create(:identity)) }

  describe '#protocol_details_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(dashboard_protocol_path(protocol), any_args)
        helper.protocol_details_button(protocol)
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(protocol_path(protocol, srid: 1), any_args)
        helper.protocol_details_button(protocol, srid: 1)
      end
    end
  end

  describe '#edit_protocol_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(edit_dashboard_protocol_path(protocol), any_args)
          helper.edit_protocol_button(protocol, permission: true)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.edit_protocol_button(protocol, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(edit_protocol_path(protocol, srid: 1), any_args)
        helper.edit_protocol_button(protocol, srid: 1)
      end
    end
  end

  describe '#push_to_oncore_button' do
    before(:each) {
      ActionView::Base.send(:define_method, :current_user) { FactoryBot.create(:identity, ldap_uid: "id@musc.edu") }
      allow(helper).to receive(:in_dashboard?).and_return(true)
    }

    context 'with OnCore' do
      stub_config("use_oncore", true)

      context 'with permissions' do
        stub_config("oncore_endpoint_access", ["id@musc.edu"])
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(push_to_oncore_dashboard_protocol_path(protocol), any_args)
          helper.push_to_oncore_button(protocol)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.push_to_oncore_button(protocol)).to be_nil
        end
      end
    end

    context 'without OnCore' do
      it 'should not render the button' do
        expect(helper.push_to_oncore_button(protocol)).to be_nil
      end
    end
  end

  describe '#archive_protocol_button' do
    before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

    context 'with permissions' do
      it 'should render the button' do
        expect(helper).to receive(:link_to).with(archive_dashboard_protocol_path(protocol), any_args)
        helper.archive_protocol_button(protocol, permission: true)
      end
    end

    context 'without permissions' do
      it 'should not render the button' do
        expect(helper.archive_protocol_button(protocol, permission: false)).to be_nil
      end
    end
  end

  describe '#display_requests_button' do
    context 'with access' do
      it 'should render Requests button with service requests' do
        sr = create(:service_request_without_validations, protocol: protocol)
        create(:sub_service_request_with_organization, service_request: sr, protocol: protocol)
        expect(helper).to receive(:link_to).with(display_requests_dashboard_protocol_path(protocol), any_args)
        helper.display_requests_button(protocol, true)
      end

      it 'should not render any button without service requests' do
        expect(helper.display_requests_button(protocol, true)).to be_nil
      end
    end

    context 'without access' do
      it 'should render the Request Access button with service requests' do
        create(:service_request_without_validations, protocol: protocol)
        user = protocol.project_roles.first.identity
        expect(helper).to receive(:link_to).with(anything, request_access_dashboard_protocol_path(protocol, recipient_id: user.id), any_args)
        helper.display_requests_button(protocol, false)
      end

      it 'should render the Request Access button without service requests' do
        user = protocol.project_roles.first.identity
        expect(helper).to receive(:link_to).with(anything, request_access_dashboard_protocol_path(protocol, recipient_id: user.id), any_args)
        helper.display_requests_button(protocol, false)
      end
    end
  end
end
