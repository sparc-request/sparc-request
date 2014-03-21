require 'spec_helper'

# index new create edit update delete show

describe StudiesController do
  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:identity) { FactoryGirl.create(:identity) }

  stub_controller

  context 'do not have a study' do
    describe 'GET new' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { :id => nil, :format => :js }.with_indifferent_access

        assigns(:protocol).class.should eq Study
        assigns(:protocol).requester_id.should eq identity.id
        assigns(:protocol).research_types_info.should_not eq nil
        assigns(:protocol).human_subjects_info.should_not eq nil
        assigns(:protocol).vertebrate_animals_info.should_not eq nil
        assigns(:protocol).investigational_products_info.should_not eq nil
        assigns(:protocol).ip_patents_info.should_not eq nil
        assigns(:protocol).study_types.should_not eq nil
        assigns(:protocol).impact_areas.should_not eq nil
        assigns(:protocol).affiliations.should_not eq nil
      end
    end

    describe 'GET create' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should create a study with the given parameters' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js, :study => { :title => 'this is the title', :funding_status => 'not in a million years' } }.with_indifferent_access
        assigns(:protocol).title.should eq 'this is the title'
        assigns(:protocol).funding_status.should eq 'not in a million years'
      end

      it 'should setup study types if the study is invalid' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js, :study => { :title => 'this is the title', :funding_status => 'not in a million years' } }.with_indifferent_access
        assigns(:protocol).study_types.should_not eq nil
        assigns(:protocol).impact_areas.should_not eq nil
        assigns(:protocol).affiliations.should_not eq nil
      end

      it 'should put the study id into the session' do
        session[:service_request_id] = service_request.id
        get :create, { :id => nil, :format => :js }.with_indifferent_access
        session[:saved_study_id].should eq assigns(:protocol).id
      end
    end
  end

  context 'already have a study' do
    let!(:study) {
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.save!(validate: false)
      project_role = FactoryGirl.create(
          :project_role,
          protocol_id: study.id,
          identity_id: identity.id,
          project_rights: "approve",
          role: "pi")
      study.reload
      study
    }

    describe 'GET edit' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:protocol).class.should eq Study
      end

      # TODO: check that populate_for_edit was called
    end

    describe 'GET update' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:service_request).should eq service_request
      end

      it 'should set study' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :update, { :id => study.id, :format => :js }.with_indifferent_access
        assigns(:protocol).class.should eq Study
        assigns(:protocol).study_types.should_not eq nil
        # TODO: check that setup_study_types was called
        # TODO: check that setup_impact_affiliations was called
        # TODO: check that setup_affiliations was called
      end
    end

    describe 'GET destroy' do
      # TODO: method is not implemented
    end
  end
end