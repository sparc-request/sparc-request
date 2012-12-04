require 'spec_helper'
require './app/controllers/identities_controller'

describe IdentitiesController do
  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }
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
end

