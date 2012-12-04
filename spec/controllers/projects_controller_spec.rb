require 'spec_helper'

# index new create edit update delete show

describe ProjectsController do
  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }
  let!(:identity) { FactoryGirl.create(:identity) }

  # Stub out all the methods in ApplicationController so we're not
  # testing them
  # TODO: refactor this into stub_helper.rb
  before(:each) do
    controller.stub!(:authenticate)

    controller.stub!(:load_defaults) do
      controller.instance_eval do
        @user_portal_link = '/user_portal'
      end
    end

    controller.stub!(:setup_session) do
      controller.instance_eval do
        @current_user = Identity.find_by_id(session[:identity_id])
        @service_request = ServiceRequest.find_by_id(session[:service_request_id])
        @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
        @line_items = @service_request.line_items
      end
    end

    controller.stub!(:setup_navigation)
  end

  context 'do not have a project' do
    describe 'GET new' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:project).class.should eq Project
        assigns(:project).requester_id.should eq identity.id
      end
    end

    describe 'GET create' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should create a project with the given parameters' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js, :project => { :title => 'this is the title', :funding_status => 'not in a million years' } }.with_indifferent_access
        assigns(:project).title.should eq 'this is the title'
        assigns(:project).funding_status.should eq 'not in a million years'
      end

      it 'should put the project id into the session' do
        session[:service_request_id] = service_request.id
        get :create, { :id => service_request.id, :format => :js }.with_indifferent_access
        session[:saved_project_id].should eq assigns(:project).id
      end

      it 'should flash a notice to the user if it created a valid project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = service_request.id
        get :create, {
          :id => service_request.id,
          :format => :js,
          :project => {
            :short_title     => 'foo',
            :title           => 'this is the title',
            :funding_status  => 'not in a million years',
            :funding_source  => 'God',
            :project_roles_attributes  => [ { :role => 'pi', :project_rights => 'jack squat', :identity_id => identity.id } ],
            :requester_id    => identity.id,
          }
        }.with_indifferent_access
        assigns(:project).valid?.should eq true
        assigns(:project).errors.messages.should eq({ })
        flash[:notice].should eq 'New project created'
      end

      it 'should not flash a notice to the user if it did not create a valid project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = service_request.id
        get :create, {
          :id => service_request.id,
          :format => :js,
        }.with_indifferent_access
        assigns(:project).valid?.should eq false
        flash[:notice].should eq nil
      end
    end
  end

  context 'already have a project' do
    let!(:project) {
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.save!(validate: false)
      project_role = FactoryGirl.create(
          :project_role,
          protocol_id: project.id,
          identity_id: identity.id,
          project_rights: "approve",
          role: "pi")
      project.reload
      project
    }

    describe 'GET edit' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => project.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => project.id, :format => :js }.with_indifferent_access
        assigns(:project).class.should eq Project
      end
    end

    describe 'GET update' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => project.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => project.id, :format => :js }.with_indifferent_access
        assigns(:project).class.should eq Project
      end
    end

    describe 'GET destroy' do
      # TODO: method is not implemented
    end
  end
end

