# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

describe Portal::AssociatedUsersController do
  stub_portal_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:identity2) { FactoryGirl.create(:identity) }
  let!(:project_role) { FactoryGirl.create(:project_role, protocol_id: project.id, identity_id: identity.id, project_rights: "approve", role: "pi") }
  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }

  describe 'GET show' do
    it 'should set user if user is an associated user' do
      get(:show, {
        format: :json,
        id: identity.id,
        protocol_id: project.id,
      }.with_indifferent_access)

      assigns(:user).should eq identity
    end

    it 'should not set user if user is not an associated user' do
      get(:show, {
        format: :json,
        id: identity2.id,
        protocol_id: project.id,
      }.with_indifferent_access)

      assigns(:user).should eq nil
    end
  end

  describe 'POST edit' do
    it 'should set identity' do
      post(:edit, {
        format: :json,
        id: project.project_roles[0].id,
        identity_id: identity.id,
        protocol_id: project.id,
      }.with_indifferent_access)
      assigns(:identity).should eq identity
    end

    it 'should set protocol_role' do
      post(:edit, {
        format: :json,
        id: project.project_roles[0].id,
        identity_id: identity.id,
        protocol_id: project.id,
      }.with_indifferent_access)
      assigns(:protocol_role).should eq project.project_roles[0]
    end

    it 'should set sub_service_request if sub_service_request_id is set' do
      post(:edit, {
        format: :json,
        identity_id: identity.id,
        id: project.project_roles[0].id,
        protocol_id: project.id,
        sub_service_request_id: sub_service_request.id,
      }.with_indifferent_access)
      assigns(:sub_service_request).should eq sub_service_request
    end
  end

  describe 'POST new' do
    it 'should set identity' do
      post(:new, {
        format: :json,
        id: project.project_roles[0].id, # not used by new, but we supply it anyway
        user_id: identity.id,
        protocol_id: project.id,
      }.with_indifferent_access)
      assigns(:identity).should eq identity
    end

    it 'should set protocol_role' do
      post(:new, {
        format: :json,
        id: project.project_roles[0].id, # not used by new, but we supply it anyway
        user_id: identity.id,
        protocol_id: project.id,
      }.with_indifferent_access)
      assigns(:protocol_role).should_not eq project.project_roles[0]
      assigns(:protocol_role).identity eq identity
    end

  end

  describe 'POST create' do
    it 'should set procotol_role' do
      # TODO
    end

    it 'should set identity' do
      # TODO
    end

    it 'should set sub_service_request if sub_service_request_id is sent' do
    end

    it "should set protocol to the sub_service_request_id's protocol if sub_service_request_id is sent" do
    end

    it "should create the associated user relationship" do
      # TODO
    end

    it "should fix the booleans" do
      # TODO
    end
  end

  describe 'POST update' do
    it "should update the associated user" do
      # TODO
    end
  
    it "should fix the booleans" do
      # TODO
    end
  
    it "should change the proxy rights" do
      # TODO
    end
  end

  describe 'POST destroy' do
    # TODO
  end

  describe 'GET search' do
    # TODO
  end

  # include EntityHelpers
  #
  # render_views
  #
  # before(:each) do
  #   @protocol = make_project :short_title => "Obvious Waste of Taxpayer Dollars"
  #   @user = make_user :first_name => "Gunnels", :last_name => "Marcus", :email => "chester@wester.bear"
  #   @new_user = make_user :first_name => "Cates", :last_name => "Andronicus", :email => "catesa@musc.edu"
  #   attach_user_to_project(@user, @protocol, 'pi')
  # end
  #
  # describe "GET protocol/:id/associated_users/new" do
  #   it "should attach the correct project on new" do
  #     get 'new', :protocol_id => @protocol['id']
  #     assigns[:protocol].id.should eq(@protocol['id'])
  #   end
  # end
  #
  # describe "POST protocol/:id/associated_users/" do
  #
  #   describe "with valid params" do
  #
  #     before(:each) do
  #       post 'create', :protocol_id => @protocol['id'], :associated_user => @new_user
  #     end
  #
  #     it "should create the associated user relationship" do
  #       assigns[:rel]['relationship_type'].should eq('project_role')
  #       assigns[:rel]['attributes']['last_name'].should eq(@new_user['last_name'])
  #       assigns[:rel]['from'].should eq(@protocol['id'])
  #       assigns[:rel]['to'].should eq(@new_user['id'])
  #       JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(2)
  #     end
  #
  #     it "should fix the booleans" do
  #       assigns[:rel]['attributes']['view_only_rights'].should be_false
  #       assigns[:rel]['attributes']['req_app_services'].should_not eq("false")
  #     end
  #
  #   end
  #
  # end
  #
  # describe "PUT protocol/:id/associated_users/:id" do
  #
  #   describe "with valid params" do
  #
  #     before(:each) do
  #       pr_id = JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).first['relationship_id']
  #       put 'update', :protocol_id => @protocol['id'], :id => @user['id'], :associated_user => {:pr_id => pr_id, :subspecialty => '3421', :auth_change_study => 'true'}
  #     end
  #
  #     it "should update the associated user" do
  #       assigns[:rel]['attributes']['subspecialty'].should eq('3421')
  #       JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(1)
  #     end
  #
  #     it "should fix the booleans" do
  #       assigns[:rel]['attributes']['view_only_rights'].should eq(false)
  #       assigns[:rel]['attributes']['req_app_services'].should_not eq("false")
  #     end
  #
  #     it "should change the proxy rights" do
  #       assigns[:rel]['attributes']['auth_change_study'].should eq(true)
  #     end
  #
  #   end
  #
  # end
  #
  # describe "DELETE protocol/:id/associated_users/:id" do
  #
  #   it "should delete the associated user relationship" do
  #     pr_id = JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).first['relationship_id']
  #     delete 'destroy', :protocol_id => @protocol['id'], :id => pr_id
  #     JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(0)
  #   end
  #
  # end

end
