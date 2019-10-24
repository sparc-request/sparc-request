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

RSpec.describe Dashboard::DocumentsController do
  describe "DELETE #destroy" do
    let!(:before_filters) { find_before_filters }
    let(:logged_in_user) { create(:identity) }
    let(:other_user) { create(:identity) }

    before :each do
      log_in_dashboard_identity(obj: logged_in_user)
    end

    context 'user is authorized to edit protocol' do
      before :each do
        @protocol       = create(:protocol_without_validations, primary_pi: logged_in_user)
        organization    = create(:organization)
        service_request = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                          create(:super_user, identity: logged_in_user, organization: organization)
        @document       = create(:document, protocol: @protocol)
        
        delete :destroy, params: { id: @document.id, format: :js }, xhr: true
      end

      it 'should assign @document' do
        expect(assigns(:document)).to eq(@document)
      end

      it 'should assign @protocol' do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should assign @admin' do
        expect(assigns(:admin)).to eq(true)
      end

      it 'should assign @authorization' do
        expect(assigns(:authorization)).to be
      end

      it 'should destroy the document' do
        expect(Document.count).to eq(0)
      end

      it 'should not call before_filter #protocol_authorizer_view' do
        expect(before_filters.include?(:protocol_authorizer_view)).to eq(false)
      end

      it 'should call before_filter #find_document' do
        expect(before_filters.include?(:find_document)).to eq(true)
      end

      it 'should call before_filter #find_protocol' do
        expect(before_filters.include?(:find_protocol)).to eq(true)
      end

      it 'should call before_filter #find_admin_for_protocol' do
        expect(before_filters.include?(:find_admin_for_protocol)).to eq(true)
      end

      it 'should call before_filter #protocol_authorizer_edit' do
        expect(before_filters.include?(:protocol_authorizer_edit)).to eq(true)
      end

      it 'should call before_filter #authorize_admin_access_document' do
        expect(before_filters.include?(:authorize_admin_access_document)).to eq(true)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/documents/destroy" }
    end

    context 'user is not authorized to edit protocol' do
      before :each do
        protocol  = create(:protocol_without_validations, primary_pi: other_user)
        document  = create(:document, protocol: protocol)
        
        delete :destroy, params: { id: document.id }, xhr: true
      end

      it 'should not destroy the document' do
        expect(Document.count).to eq(1)
      end

      it { is_expected.to respond_with 302 }
    end

    context 'user has admin access to document' do
      before :each do
        protocol        = create(:protocol_without_validations, primary_pi: other_user)
        organization    = create(:organization)
        service_request = create(:service_request_without_validations, protocol: protocol)
        ssr             = create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                          create(:super_user, identity: logged_in_user, organization: organization)
        document        = create(:document, protocol: protocol)

        document.sub_service_requests = [ssr]

        delete :destroy, params: { id: document.id, format: :js }, xhr: true
      end

      it 'should destroy the document' do
        expect(Document.count).to eq(0)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/documents/destroy" }
    end

    context 'user does not have admin access to document' do
      before :each do
        protocol  = create(:protocol_without_validations, primary_pi: other_user)
        document  = create(:document, protocol: protocol)

        delete :destroy, params: { id: document.id, format: :js }, xhr: true
      end

      it 'should not destroy the document' do
        expect(Document.count).to eq(1)
      end

      it { is_expected.to respond_with 302 }
    end
  end
end