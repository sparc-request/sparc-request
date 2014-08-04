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
require 'net/ldap' # TODO: not sure why this is necessary

describe "Identity" do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project
  

  describe "helper methods" do

    let!(:identity) { FactoryGirl.create(:identity, first_name: "ash", last_name: "ketchum", email: "ash@theverybest.com") }

    describe "full_name" do

      it "should return the full name if both first and last name are present" do
        identity.full_name.should eq("Ash Ketchum")
      end

      it "should return what it can (without extra whitespace) if a piece is missing" do
        identity.update_attribute(:last_name, nil)
        identity.full_name.should eq("Ash")
      end

    end

    describe "display name" do

      it "should return the display name if all elements are present" do
        identity.display_name.should eq("Ash Ketchum (ash@theverybest.com)")
      end

      it "should return what it can (without extra whitespace) if a piece is missing" do
        identity.update_attribute(:email, nil)
        identity.display_name.should eq("Ash Ketchum ()")
      end

    end

  end

  describe "searching identities" do

    # Several of these tests will put a bunch of stuff into the logs,
    # So while the tests are passing you will see a bunch of text in the spec logs.

    let!(:identity) { FactoryGirl.create(:identity, first_name: "ash", last_name: "ketchum", email: "ash@theverybest.com", ldap_uid: 'ash151@musc.edu') }

    it "should find an existing identity" do
      Identity.search("ash151").should eq([identity])
    end

    it "should create an identity for a non-existing ldap_uid" do
      Identity.all.count.should eq(3)
      Identity.search("ash")
      Identity.all.count.should eq(4)
    end

    it "should return an empty array if it cannot find anything" do
      Identity.search("gary").should eq([])
    end

    it "should still search the database if ldap fails for some reason" do
      FactoryGirl.create(:identity, :ldap_uid => 'error')
      # These search terms will cause ldap to raise an exception, however,
      # the search results will still return the 'error' identity.
      Identity.search('error').should_not be_empty()
    end

    it "should return identities without an e-mail address" do
      Identity.all.count.should eq(3)
      Identity.search('iamabadldaprecord').should_not be_empty()
      Identity.all.count.should eq(4)
    end

    it "should still search the database if the identity creation fails for some reason" do
      FactoryGirl.create(:identity, first_name: "ash", last_name: "evil", email: "another_ash@s-mart.com", ldap_uid: 'ashley@musc.edu')
      Identity.search('ash')
    end

  end

  describe "rights" do

    let!(:user)                 {FactoryGirl.create(:identity)}
    let!(:user2)                {FactoryGirl.create(:identity)}           
    let!(:catalog_manager)      {FactoryGirl.create(:catalog_manager, identity_id: user.id, organization_id: institution.id)}
    let!(:super_user)           {FactoryGirl.create(:super_user, identity_id: user.id, organization_id: institution.id)}
    let!(:service_provider)     {FactoryGirl.create(:service_provider, identity_id: user.id, organization_id: institution.id)}
    let!(:clinical_provider)    {FactoryGirl.create(:clinical_provider, identity_id: user2.id, organization_id: core.id)}
    let!(:ctrc_provider)        {FactoryGirl.create(:clinical_provider, identity_id: user2.id, organization_id: program.id)}
    let!(:project_role)         {FactoryGirl.create(:project_role, identity_id: user.id, protocol_id: project.id, project_rights: 'approve')}

    describe "permission methods" do
    

      describe "can edit request " do

        it "should accept either a ssr or sr as an argument" do
          user.can_edit_request?(service_request).should eq(true)
          user.can_edit_request?(sub_service_request).should eq(true)
        end

        it "should return false if the users rights are not 'approve' or request" do
          project_role.update_attributes(project_rights: 'none')
          service_request.update_attributes(service_requester_id: user2.id)
          user.can_edit_request?(service_request).should eq(false)
          user.can_edit_request?(sub_service_request).should eq(false)
        end

        it "should return true no matter what the service request's status is" do
          service_request.update_attributes(status: 'approved')
          user.can_edit_request?(service_request).should eq(true)
        end

        it "should return true no matter what the sub service request's status is" do
          sub_service_request.update_attributes(status: 'approved')
          user.can_edit_request?(sub_service_request).should eq(true)
        end
      end

      describe "can edit entity" do

        it "should return true if the user is a catalog manager for a given organization" do
          user.can_edit_entity?(institution).should eq(true)
        end

        it "should return false if the user is not a catalog manager for a given organization" do
          random_user = FactoryGirl.create(:identity)
          random_user.can_edit_entity?(institution).should eq(false)
        end
      end

      describe "can edit historical data for" do

        it "should return true if 'edit historic data' flag is set for the user's catalog manager relationship" do
          catalog_manager.update_attributes(edit_historic_data: true)
          user.can_edit_historical_data_for?(institution).should eq(true)
        end

        it "should return false if the flag is not set" do
          user.can_edit_historical_data_for?(institution).should eq(false)
        end
      end

      describe "can edit fulfillment" do

        it "should return true if the user is a super user for an organization's parent" do
          user.can_edit_fulfillment?(provider).should eq(true)
        end

        it "should return true if the user is a service provider for a given organization" do
          user.can_edit_fulfillment?(institution).should eq(true)
        end

        it "should return false if these conditions are not met" do
          random_user = FactoryGirl.create(:identity)
          random_user.can_edit_fulfillment?(institution).should eq(false)
        end 
      end

      describe "can edit core" do

        it "should return true if the user is a clinical provider on the given core" do
          user2.can_edit_core?(core.id).should eq(true)
        end

        it "should return true if the user is a super user on the given core" do
          user.can_edit_core?(core.id).should eq(true)
        end

        it "should return false if the user is not a clinical provider on a given core" do
          random_user = FactoryGirl.create(:identity)
          random_user.can_edit_core?(core.id).should eq(false)
        end
      end

      describe "clinical provider for ctrc" do

        it "should return true if the user is a clinical provider on the ctrc" do
          program.tag_list.add("ctrc")
          program.save
          user2.clinical_provider_for_ctrc?.should eq(true)
        end

        it "should return false if the user is not a clinical provider on the ctrc" do
          user.clinical_provider_for_ctrc?.should eq(false)
        end
      end
    end

    describe "collection methods" do
      
      describe "catalog manager organizations" do

        it "should collect all organizations that the user has catalog manager permissions on" do
          user.catalog_manager_organizations.should include(institution)
        end

        it "should also collect all child organizations" do
          user.catalog_manager_organizations.should include(provider, program)
        end
      end

      describe "admin organizations" do

        it "should collect all organizations that the user has super user permissions on" do
          user.admin_organizations.should include(institution)
        end

        it "should also collect all child organizations" do
          user.admin_organizations.should include(provider, program)
        end

        it "should not ignore nil organizations" do
          sp = FactoryGirl.create(:service_provider, identity_id: user.id, organization_id: 9999)
          lambda {user.admin_organizations}.should_not raise_exception
        end
      end

      describe "available workflow states" do

        it "should not return 'CTRC Review' and 'CTRC Approved' if user does not have ctrc permissions" do
          user.available_workflow_states.should_not include('CTRC Review', 'CTRC Approved')
        end

        it "should return 'CTRC Review' and 'CTRC Aproved' if user does have ctrc permissions" do
          organization = FactoryGirl.create(:organization)
          organization.tag_list = "ctrc"
          organization.save
          super_user.update_attributes(organization_id: organization.id)
          user.available_workflow_states.should include('Nexus Review', 'Nexus Approved')
        end
      end

      describe "admin service requests by status" do

        it "should return all of a user's sub service requests under admin organizations sorted by status" do
          hash = user.admin_service_requests_by_status
          hash.should include('draft')
        end
        it "should return a specific organization's sub service requests if givin an org id" do
          sub_service_request.update_attributes(status: "submitted", organization_id: institution.id)
          hash = user.admin_service_requests_by_status(institution.id)
          hash.should include('submitted')
        end
      end
    end
  end

  describe "notification methods" do

    let!(:user)               {FactoryGirl.create(:identity)}
    let!(:notification)       {FactoryGirl.create(:notification)}
    let!(:notification2)      {FactoryGirl.create(:notification)}
    let!(:user_notification)  {FactoryGirl.create(:user_notification, identity_id: user.id, notification_id: notification.id)}
    let!(:user_notification2) {FactoryGirl.create(:user_notification, identity_id: user.id, notification_id: notification2.id)}


    describe "all notifications" do

      it "should return all of a user's notifications based on their user notifications" do
        user.all_notifications.should include(notification, notification2)
      end
    end

    describe "unread notification count" do

      it "should return the correct number of unread notifications" do
        user.unread_notification_count(user).should eq(2)
      end

      it "should reduce the count by one if a message is read" do
        user_notification.update_attributes(read: true)
        user.unread_notification_count(user).should eq(1)
      end
    end
  end

  describe "validations" do

    it "should validate the presence of neccessary attributes" do
      lambda { FactoryGirl.build(:identity).save! }.should_not raise_exception
      lambda { FactoryGirl.build(:identity, :ldap_uid => nil).save! }.should raise_exception(ActiveRecord::RecordInvalid)
      lambda { FactoryGirl.build(:identity, :first_name => nil).save! }.should raise_exception(ActiveRecord::RecordInvalid)
      lambda { FactoryGirl.build(:identity, :last_name => nil).save! }.should raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
