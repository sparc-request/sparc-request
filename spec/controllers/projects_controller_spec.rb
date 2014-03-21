require 'spec_helper'

# index new create edit update delete show

describe ProjectsController do
  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:identity) { FactoryGirl.create(:identity) }

  stub_controller

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
        assigns(:protocol).class.should eq Project
        assigns(:protocol).requester_id.should eq identity.id
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
        assigns(:protocol).title.should eq 'this is the title'
        assigns(:protocol).funding_status.should eq 'not in a million years'
      end

      it 'should put the project id into the session' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        session[:saved_protocol_id].should eq assigns(:protocol).id
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
        assigns(:protocol).class.should eq Project
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
        assigns(:protocol).class.should eq Project
      end
    end

    describe 'GET destroy' do
      # TODO: method is not implemented
    end
  end
end

