require 'spec_helper'
require './app/controllers/identities_controller'

describe IdentitiesController do
  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }
  let!(:identity) { FactoryGirl.create(:identity) }

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

  let!(:project_role) {
    study.project_roles[0]
  }

  stub_controller

  describe 'GET show' do
    it 'should should set identity' do
      session[:identity_id] = identity.id
      get :show, { :id => identity.id, :format => :js }.with_indifferent_access
      assigns(:identity).should eq identity
    end

    it 'should set can_edit to false if there are no project role params' do
      session[:identity_id] = identity.id
      get :show, { :id => identity.id, :format => :js }.with_indifferent_access
      assigns(:can_edit).should eq false
    end

    it 'should set can_edit to true if there are project role params' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :show, {
        :format => :js,
        :id => identity.id,
        :study => {
          :project_roles_attributes => {
            identity.id.to_s => {
              'id' => nil,
            }
          }
        }
      }.with_indifferent_access
      assigns(:can_edit).should eq true
    end

    it 'should create a new project role if no id is given' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :show, {
        :format => :js,
        :id => identity.id,
        :study => {
          :project_roles_attributes => {
            identity.id.to_s => {
              'id' => nil,
            }
          }
        }
      }.with_indifferent_access
      assigns(:project_role).class.should eq ProjectRole
      assigns(:project_role).persisted?.should eq false
    end

    it 'should use the given project role if an id is given' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :show, {
        :format => :js,
        :id => identity.id,
        :study => {
          :project_roles_attributes => {
            identity.id.to_s => {
              :id => project_role.id,
              :role => 'pi',
              :project_rights => 'jack squat',
            }.with_indifferent_access
          }
        }
      }.with_indifferent_access

      assigns(:project_role).should eq project_role
      assigns(:project_role).project_rights.should eq 'jack squat'
    end
  end

  describe 'POST add_to_protocol' do
    it 'should set can_edit to true if true was passed in' do
      session[:identity_id] = identity.id
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => project_role.id,
          :role => '',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:can_edit).should eq true
    end

    it 'should set error if role is blank' do
      session[:identity_id] = identity.id
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => project_role.id,
          :role => '',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:error).should eq "Role can't be blank"
      assigns(:error_field).should eq 'role'
    end

    it 'should set error if role other and role_other is blank' do
      session[:identity_id] = identity.id
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => project_role.id,
          :role => 'other',
          :role_other => '',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:error).should eq "'Other' role can't be blank"
      assigns(:error_field).should eq 'role'
    end

    it 'should set protocol type' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => project_role.id,
          :role => 'head honcho',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:protocol_type).should eq 'study'
    end

    it 'should create a new project role if id is blank' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => nil,
          :role => 'head honcho',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:project_role).class.should eq ProjectRole
      assigns(:project_role).role.should eq 'head honcho'
      assigns(:project_role).identity.should eq identity
      assigns(:project_role).persisted?.should eq false
    end

    it 'should use the given project role if id is not blank' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      get :add_to_protocol, {
        :format => :js,
        :id => identity.id,
        :can_edit => true,
        :project_role => {
          :id => project_role.id,
          :role => 'head honcho',
        },
        :identity => {
          :id => identity.id,
        }
      }.with_indifferent_access
      assigns(:project_role).class.should eq ProjectRole
      assigns(:project_role).role.should eq 'head honcho'
      assigns(:project_role).identity.should eq identity
      assigns(:project_role).persisted?.should eq true
    end
  end
end

