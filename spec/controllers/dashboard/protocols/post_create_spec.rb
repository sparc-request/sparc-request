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

require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do

  describe 'POST #create' do

    context 'success' do

      before( :each ) do
        @logged_in_user = build_stubbed( :identity )
        
        protocol = build( :study_with_blank_dates )

        project_role_attributes = { "0" => { identity_id: @logged_in_user.id, role: 'primary-pi', project_rights: 'approve' } }

        @protocol_attributes = protocol.attributes.merge( { project_roles_attributes: project_role_attributes } )

        allow( StudyTypeQuestionGroup ).to receive( :active_id ).
          and_return( "active group id" )
        allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        log_in_dashboard_identity( obj: @logged_in_user )
      end

      it 'creates a new protocol record' do
        expect{ post :create, params: {
                    protocol: @protocol_attributes
                    }, xhr: true }.
                    to change{ Protocol.count }.by( 1 )
      end

      it 'creates a new service request record' do
        expect{ post :create, params: {
                    protocol: @protocol_attributes
                    }, xhr: true }.
                    to change{ ServiceRequest.count }.by( 1 )
      end

      it 'creates a new project role record' do
        expect{ post :create, params: {
                    protocol: @protocol_attributes
                    }, xhr: true }.
                    to change{ ProjectRole.count }.by( 1 )
      end

      it 'creates an extra project role record if the current user is not assigned to the protocol' do
        @protocol_attributes[:project_roles_attributes]["0"][:identity_id] = build_stubbed(:identity).id
        expect{ post :create, params: {
                    protocol: @protocol_attributes
                    }, xhr: true }.
                    to change{ ProjectRole.count }.by( 2 )
      end

      it 'receives the correct flash message' do
        post :create, params: { protocol: @protocol_attributes }, xhr: true
        expect(flash[:success]).to eq(I18n.t('protocols.created', protocol_type: @protocol_attributes['type']))
      end

    end

    context 'unsuccessful' do

      before( :each ) do
        @logged_in_user = build_stubbed( :identity )
        
        @protocol = build( :study_with_blank_dates )

        allow( StudyTypeQuestionGroup ).to receive( :active_id ).
          and_return( "active group id" )
        allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        log_in_dashboard_identity( obj: @logged_in_user )
      end

      it 'gives the correct error message' do
        post :create, params: { protocol: @protocol.attributes }, xhr: true
        expect(assigns(:errors)).to eq(assigns(:protocol).errors)
      end

      it 'does not create a new protocol record' do
        expect{ post :create, params: {
                    protocol: @protocol.attributes
                    }, xhr: true }.
                    not_to change{ Protocol.count }
      end

      it 'does not create a new service request record' do
        expect{ post :create, params: {
                    protocol: @protocol.attributes
                    }, xhr: true }.
                    not_to change{ ServiceRequest.count }
      end

      it 'does not create a new project role record' do
        expect{ post :create, params: {
                    protocol: @protocol.attributes
                    }, xhr: true }.
                    not_to change{ ProjectRole.count }
      end

    end

  end

end