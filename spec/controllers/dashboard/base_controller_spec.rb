# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
  controller do
    def show
      find_admin_for_protocol
      head :ok
    end

    def index
      find_admin_for_protocol
      protocol_authorizer_view
      head :ok if @authorization.can_view? || @admin
    end

    def new
      find_admin_for_protocol
      protocol_authorizer_edit
      head :ok if @authorization.can_edit? || @admin
    end
  end

  describe '#find_admin_for_protocol' do
    before :each do
        @user            = create(:identity)
        @protocol        = create(:protocol_without_validations)
        @organization    = create(:organization)
        @service_request = create(:service_request_without_validations,
                                  protocol: @protocol)
        @ssr             = create(:sub_service_request_without_validations,
                                  organization: @organization,
                                  service_request: @service_request,
                                  status: 'complete',
                                  protocol_id: @protocol.id)
        controller.instance_variable_set(:@protocol, @protocol)
      end

    context 'user is an admin of an organization' do
      it 'should set @admin to true when the user is a Super User' do
        create(:super_user, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :show, params: { id: "id" }
        expect(assigns(:admin)).to eq(true)
      end
      it 'should set @admin to true when the user is a Service Provider' do
        create(:service_provider, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :show, params: { id: "id" }
        expect(assigns(:admin)).to eq(true)
      end
    end

    context 'user is not an admin of an organization' do
      it 'should set @admin to false if the user is not an admin of an organization' do
        log_in_dashboard_identity({id: @user.id})

        get :show, params: { id: "id" }
        expect(assigns(:admin)).to eq(false)
      end
    end
  end

  describe '#protocol_authorizer_view' do
    context 'user can view protocol' do
      before :each do
        @user            = create(:identity)
        @protocol        = create(:protocol_without_validations)
        @organization    = create(:organization)
        @service_request = create(:service_request_without_validations,
                                  protocol: @protocol)
        @ssr             = create(:sub_service_request_without_validations,
                                  organization: @organization,
                                  service_request: @service_request,
                                  status: 'complete',
                                  protocol_id: @protocol.id)
        controller.instance_variable_set(:@protocol, @protocol)
      end

      it 'should not render an error message for super users' do
        create(:super_user, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for service providers' do
        create(:service_provider, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for view project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'view')
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for approve project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'approve')
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for request project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'request')
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
    end

    context 'user can not view protocol' do
      before :each do
        @user     = create(:identity)
        @protocol = create(:protocol_without_validations)
        controller.instance_variable_set(:@protocol, @protocol)
      end

      it 'should render an error message for non-admin users' do
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should render an error message for user with no project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'none')
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for super users with access to empty protocols' do
        @organization    = create(:organization)
        create(:super_user, identity: @user, organization: @organization, access_empty_protocols: true)
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
    end
  end


  describe '#protocol_authorizer_edit' do
    context 'user can edit protocol' do
      before :each do
        @user            = create(:identity)
        @protocol        = create(:protocol_without_validations)
        @organization    = create(:organization)
        @service_request = create(:service_request_without_validations,
                                  protocol: @protocol)
        @ssr             = create(:sub_service_request_without_validations,
                                  organization: @organization,
                                  service_request: @service_request,
                                  status: 'complete',
                                  protocol_id: @protocol.id)
        controller.instance_variable_set(:@protocol, @protocol)
      end

      it 'should not render an error message for super users' do
        create(:super_user, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for service providers' do
        create(:service_provider, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for approve project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'approve')
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for request project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'request')
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
    end

    context 'user can not edit protocol' do
      before :each do
        @user     = create(:identity)
        @protocol = create(:protocol_without_validations)
        controller.instance_variable_set(:@protocol, @protocol)
      end

      it 'should render an error message for non-admin users' do
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should render an error message for user with no project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'none')
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should render an error message for view project rights' do
        create(:project_role, identity: @user, protocol: @protocol, project_rights: 'view')
        log_in_dashboard_identity({id: @user.id})

        get :new
        expect(controller).to render_template(partial: 'dashboard/shared/_authorization_error')
      end
      it 'should not render an error message for super users with access to empty protocols' do
        @organization    = create(:organization)
        create(:super_user, identity: @user, organization: @organization, access_empty_protocols: true)
        log_in_dashboard_identity({id: @user.id})

        get :index
        expect(controller).to_not render_template(partial: 'dashboard/shared/_authorization_error')
      end
    end
  end
end
