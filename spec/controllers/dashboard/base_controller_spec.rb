require 'rails_helper'

RSpec.describe Dashboard::BaseController, type: :controller do
  controller do
    def show
      find_admin_for_protocol
      render nothing: true
    end

    def index
      find_admin_for_protocol
      protocol_authorizer_view
      render nothing: true if @authorization.can_view? || @admin
    end

    def new
      find_admin_for_protocol
      protocol_authorizer_edit
      render nothing: true if @authorization.can_edit? || @admin
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
                                  status: 'complete')
        controller.instance_variable_set(:@protocol, @protocol)
      end

    context 'user is an admin of an organization' do
      it 'should set @admin to true when the user is a Super User' do
        create(:super_user, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :show, id: "id"
        expect(assigns(:admin)).to eq(true)
      end
      it 'should set @admin to true when the user is a Service Provider' do
        create(:service_provider, identity: @user, organization: @organization)
        log_in_dashboard_identity({id: @user.id})

        get :show, id: "id"
        expect(assigns(:admin)).to eq(true)
      end
    end

    context 'user is not an admin of an organization' do
      it 'should set @admin to false if the user is not an admin of an organization' do
        log_in_dashboard_identity({id: @user.id})

        get :show, id: "id"
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
                                  status: 'complete')
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
                                  status: 'complete')
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
    end
  end
end