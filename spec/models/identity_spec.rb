require 'spec_helper'
require 'net/ldap' # TODO: not sure why this is necessary

describe "Identity" do
  

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

    before(:each) do
      ldap = double(port: 636, base: 'ou=people,dc=musc,dc=edu', encryption: :simple_tls)
      results = [
        double(givenname: ["Ash"], sn: ["Ketchum"], mail: ["ash@theverybest.com"], uid: ["ash151"]),
        double(givenname: ["Ash"], sn: ["Williams"], mail: ["ash@s-mart.com"], uid: ["ashley"])
      ]
      ldap.stub(:search).with(filter: create_ldap_filter('ash151')).and_return([results[0]])
      ldap.stub(:search).with(filter: create_ldap_filter('ash')).and_return(results)
      ldap.stub(:search).with(filter: create_ldap_filter('gary')).and_return([])
      ldap.stub(:search).with(filter: create_ldap_filter('error')).and_raise('error')
      ldap.stub(:search).with(filter: create_ldap_filter('duplicate')).and_return()
      Net::LDAP.stub(:new).and_return(ldap)
    end

    it "should find an existing identity" do
      Identity.search("ash151").should eq([identity])
    end

    it "should create an identity for a non-existing ldap_uid" do
      Identity.all.count.should eq(1)
      Identity.search("ash")
      Identity.all.count.should eq(2)
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

    it "should still search the database if the identity creation fails for some reason" do
      FactoryGirl.create(:identity, first_name: "ash", last_name: "evil", email: "another_ash@s-mart.com", ldap_uid: 'ashley@musc.edu')
      Identity.search('ash')
    end

  end

  describe "rights" do

    let!(:institution)          {FactoryGirl.create(:institution)}
    let!(:institution2)         {FactoryGirl.create(:institution)}
    let!(:institution3)         {FactoryGirl.create(:institution)}
    let!(:provider)             {FactoryGirl.create(:provider, parent_id: institution.id)}
    let!(:program)              {FactoryGirl.create(:program, parent_id: provider.id)} 
    let!(:provider2)            {FactoryGirl.create(:provider, parent_id: institution.id)}
    let!(:user)                 {FactoryGirl.create(:identity)}
    let!(:catalog_manager)      {FactoryGirl.create(:catalog_manager, identity_id: user.id, organization_id: institution2.id)}
    let!(:catalog_manager2)     {FactoryGirl.create(:catalog_manager, identity_id: user.id, organization_id: institution.id)}
    let!(:super_user)           {FactoryGirl.create(:super_user, identity_id: user.id, organization_id: institution.id)}
    let!(:service_provider)     {FactoryGirl.create(:service_provider, identity_id: user.id, organization_id: institution.id)}
    
    let!(:project) {
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.save!(validate: false)
      project
    }
    let!(:project_role)         {FactoryGirl.create(:project_role, identity_id: user.id, protocol_id: project.id, project_rights: 'approve')}
    let!(:service_request)      {FactoryGirl.create(:service_request, status: 'draft', service_requester_id: user.id, protocol_id: project.id)}
    let!(:service_request2)     {FactoryGirl.create(:service_request, status: 'submitted', service_requester_id: user.id, protocol_id: project.id)}
    let!(:sub_service_request)  {FactoryGirl.create(:sub_service_request, status: 'draft', service_request_id: service_request.id,
                                                    organization_id: institution.id)}
    let!(:sub_service_request2) {FactoryGirl.create(:sub_service_request, status: 'draft', service_request_id: service_request.id)}

    describe "permission methods" do
    
      describe "can edit service request" do

        it "should return true if service request is in 'draft' or 'submitted' status" do
          user.can_edit_service_request?(service_request).should eq(true)
          user.can_edit_service_request?(service_request2).should eq(true)
        end

        it "should return false if moved from 'draft' or 'submitted' status" do
          service_request.update_attributes(status: 'approved')
          user.can_edit_service_request?(service_request).should eq(false)
        end

        it "should return false if its sub service requests are not uniformly either 'draft' or 'submitted'" do
          sub_service_request.update_attributes(status: 'submitted')
          user.can_edit_service_request?(service_request).should eq(false)
        end

        it "should return false if the user's project rights are not either 'approve' or 'request'" do
          project_role.update_attributes(project_rights: 'none')
          user.can_edit_service_request?(service_request).should eq(false)
        end
      end

      describe "can edit sub service request" do

        it "should return true if the sub service request is in either 'draft' or 'submitted' status" do
          user.can_edit_sub_service_request?(sub_service_request).should eq(true)
        end

        it "should return false if moved from 'draft' or 'submitted' status" do
          sub_service_request.update_attributes(status: 'approved')
          user.can_edit_sub_service_request?(sub_service_request).should eq(false)
        end
      end

      describe "can edit entity" do

        it "should return true if the user is a catalog manager for a given organization" do
          user.can_edit_entity?(institution).should eq(true)
        end

        it "should return false if the user is not a catalog manager for a given organization" do
          user.can_edit_entity?(institution3).should eq(false)
        end
      end

      describe "can edit historical data for" do

        it "should return true if 'edit historic data' flag is set for the user's catalog manager relationship" do
          catalog_manager2.update_attributes(edit_historic_data: true)
          user.can_edit_historical_data_for?(institution).should eq(true)
        end

        it "should return false if the flag is not set" do
          user.can_edit_historical_data_for?(institution).should eq(false)
        end
      end

      describe "can edit fulfillment" do

        it "should return true if the user is a super user for a given organization" do
          user.can_edit_fulfillment?(provider).should eq(true)
        end

        it "should return true if the user is a service provider for a given organization" do
          user.can_edit_fulfillment?(institution).should eq(true)
        end

        it "should return true if the user is either a super user or a service provider for any of its parents" do
          user.can_edit_fulfillment?(provider2).should eq(true)
        end

        it "should return false if these conditions are not met" do
          user.can_edit_fulfillment?(institution2).should eq(false)
        end 
      end
    end

    describe "collection methods" do
      
      describe "catalog manager organizations" do

        it "should collect all organizations that the user has catalog manager permissions on" do
          user.catalog_manager_organizations.should include(institution, institution2)
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
          user.available_workflow_states.should include('CTRC Review', 'CTRC Approved')
        end
      end

      describe "admin service requests by status" do

        it "should return all of a user's sub service requests under admin organizations sorted by status" do
          hash = user.admin_service_requests_by_status
          hash.should include('draft')
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
