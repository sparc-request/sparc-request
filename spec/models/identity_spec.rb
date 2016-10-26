# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require 'rails_helper'
require 'net/ldap' # TODO: not sure why this is necessary

RSpec.describe "Identity" do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project


  describe "helper methods" do

    let!(:identity) { create(:identity, first_name: "ash", last_name: "ketchum", email: "ash@theverybest.com") }

    describe "full_name" do

      it "should return the full name if both first and last name are present" do
        expect(identity.full_name).to eq("Ash Ketchum")
      end

      it "should return what it can (without extra whitespace) if a piece is missing" do
        identity.update_attribute(:last_name, nil)
        expect(identity.full_name).to eq("Ash")
      end

    end

    describe "display name" do

      it "should return the display name if all elements are present" do
        expect(identity.display_name).to eq("Ash Ketchum (ash@theverybest.com)")
      end

      it "should return what it can (without extra whitespace) if a piece is missing" do
        identity.update_attribute(:email, nil)
        expect(identity.display_name).to eq("Ash Ketchum ()")
      end

    end

  end

  describe "searching identities" do

    # Several of these tests will put a bunch of stuff into the logs,
    # So while the tests are passing you will see a bunch of text in the spec logs.

    let!(:identity) { create(:identity, first_name: "ash", last_name: "ketchum", email: "ash@theverybest.com", ldap_uid: 'ash151@musc.edu') }

    it "should find an existing identity" do
      expect(Identity.search("ash151")).to eq([identity])
    end

    it "should create an identity for a non-existing ldap_uid" do
      expect(Identity.all.count).to eq(3)
      Identity.search("ash")
      expect(Identity.all.count).to eq(4)
    end

    it "should return an empty array if it cannot find anything" do
      expect(Identity.search("gary")).to eq([])
    end

    it "should still search the database if ldap fails for some reason" do
      create(:identity, ldap_uid: 'error')
      # These search terms will cause ldap to raise an exception, however,
      # the search results will still return the 'error' identity.
      expect(Identity.search('error')).not_to be_empty()
    end

    it "should return identities without an e-mail address" do
      expect(Identity.all.count).to eq(3)
      expect(Identity.search('iamabadldaprecord')).not_to be_empty()
      expect(Identity.all.count).to eq(4)
    end

    it "should still search the database if the identity creation fails for some reason" do
      create(:identity, first_name: "ash", last_name: "evil", email: "another_ash@s-mart.com", ldap_uid: 'ashley@musc.edu')
      Identity.search('ash')
    end

  end

  describe "rights" do

    let!(:user)                 {create(:identity, ldap_uid: 'slickwilly@musc.edu')}
    let!(:user2)                {create(:identity, ldap_uid: 'superfly@musc.edu')}
    let!(:catalog_manager)      {create(:catalog_manager, identity_id: user.id, organization_id: institution.id)}
    let!(:super_user)           {create(:super_user, identity_id: user.id, organization_id: institution.id)}
    let!(:service_provider)     {create(:service_provider, identity_id: user.id, organization_id: institution.id, is_primary_contact: true)}
    let!(:clinical_provider)    {create(:clinical_provider, identity_id: user2.id, organization_id: core.id)}
    let!(:ctrc_provider)        {create(:clinical_provider, identity_id: user2.id, organization_id: program.id)}
    let!(:project_role)         {create(:project_role, identity_id: user.id, protocol_id: project.id, project_rights: 'approve')}
    let!(:request)              {create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id)}

    describe "permission methods" do


      describe "can edit service request " do


        it "should return false if the users rights are not 'approve' or request" do
          project_role.update_attributes(project_rights: 'none')
          service_request.update_attributes(service_requester_id: user2.id)
          expect(user.can_edit_service_request?(service_request)).to eq(false)
        end

        it "should return true no matter what the service request's status is" do
          service_request.update_attributes(status: 'approved')
          expect(user.can_edit_service_request?(service_request)).to eq(true)
        end
      end

      describe "can edit sub service request" do

        it "should return true if the user has the correct rights, and if nexus ssr has the correct status" do
          program.tag_list = 'ctrc'
          program.save
          expect(user.can_edit_sub_service_request?(sub_service_request)).to eq(true)
        end

        it "should return true if not a nexus request, regardless of status" do
          request.update_attributes(status: "complete")
          expect(user.can_edit_sub_service_request?(request)).to eq(true)
        end

        it "should return false if the user does not have correct rights" do
          project_role.update_attributes(project_rights: 'none')
          service_request.update_attributes(service_requester_id: user2.id)
          expect(user.can_edit_sub_service_request?(sub_service_request)).to eq(false)
        end
      end

      describe "can edit entity" do

        it "should return true if the user is a catalog manager for a given organization" do
          expect(user.can_edit_entity?(institution)).to eq(true)
        end

        it "should return false if the user is not a catalog manager for a given organization" do
          random_user = create(:identity)
          expect(random_user.can_edit_entity?(institution)).to eq(false)
        end
      end

      describe "can edit historical data for" do

        it "should return true if 'edit historic data' flag is set for the user's catalog manager relationship" do
          catalog_manager.update_attributes(edit_historic_data: true)
          expect(user.can_edit_historical_data_for?(institution)).to eq(true)
        end

        it "should return false if the flag is not set" do
          expect(user.can_edit_historical_data_for?(institution)).to eq(false)
        end
      end

      describe "can edit core" do

        it "should return true if the user is a clinical provider on the given core" do
          expect(user2.can_edit_core?(core.id)).to eq(true)
        end

        it "should return true if the user is a super user on the given core" do
          expect(user.can_edit_core?(core.id)).to eq(true)
        end

        it "should return false if the user is not a clinical provider on a given core" do
          random_user = create(:identity)
          expect(random_user.can_edit_core?(core.id)).to eq(false)
        end
      end

      describe "clinical provider for ctrc" do

        it "should return true if the user is a clinical provider on the ctrc" do
          program.tag_list.add("ctrc")
          program.save
          expect(user2.clinical_provider_for_ctrc?).to eq(true)
        end

        it "should return false if the user is not a clinical provider on the ctrc" do
          expect(user.clinical_provider_for_ctrc?).to eq(false)
        end
      end

      describe "is service provider" do

        it "should return true if the user is a service provider for a given ssr's organization or any of it's parents" do
          expect(user.is_service_provider?(request)).to eq(true)
        end

        it "should return false if the user is not a service provider in the org tree" do
          expect(user2.is_service_provider?(request)).to eq(false)
        end
      end
    end

    describe "collection methods" do

      describe "catalog manager organizations" do

        it "should collect all organizations that the user has catalog manager permissions on" do
          expect(user.catalog_manager_organizations).to include(institution)
        end

        it "should also collect all child organizations" do
          expect(user.catalog_manager_organizations).to include(provider, program)
        end
      end

      describe "admin organizations" do

        it "should collect all organizations that the user has super user permissions on" do
          expect(user.admin_organizations).to include(institution)
        end

        it "should also collect all child organizations" do
          expect(user.admin_organizations).to include(provider, program)
        end

        it "should not ignore nil organizations" do
          create(:service_provider, identity_id: user.id, organization_id: 9999)
          expect(lambda {user.admin_organizations}).not_to raise_exception
        end
      end
    end
  end

  describe "notification methods" do
    describe "#unread_notification_count" do
      context "with :sub_service_request_id" do
        it "should return number of unread notifications only associated with specified SubServiceRequest" do
          user1 = create(:identity)
          user2 = create(:identity)

          # expect
          create(:notification_without_validations, originator_id: user1.id, read_by_originator: false, sub_service_request_id: 1)

          # don't expect
          create(:notification_without_validations, originator_id: user1.id, read_by_originator: false, sub_service_request_id: 2)
          create(:notification_without_validations, originator_id: user2.id, read_by_originator: false)

          expect(user1.unread_notification_count(1)).to eq(1)
        end
      end

      context "without :sub_service_request_id" do
        it "should return number of unread notifications" do
          user1 = create(:identity)
          user2 = create(:identity)

          # expect
          create(:notification_without_validations, originator_id: user1.id, read_by_originator: false, sub_service_request_id: 1)
          create(:notification_without_validations, originator_id: user1.id, read_by_originator: false, sub_service_request_id: 2)

          # don't expect
          create(:notification_without_validations, originator_id: user2.id, read_by_originator: false)

          expect(user1.unread_notification_count).to eq(2)
        end
      end
    end
  end

  describe "validations" do

    it "should validate the presence of neccessary attributes" do
      expect(lambda { build(:identity).save! }).not_to raise_exception
      expect(lambda { build(:identity, ldap_uid: nil).save! }).to raise_exception(ActiveRecord::RecordInvalid)
      expect(lambda { build(:identity, first_name: nil).save! }).to raise_exception(ActiveRecord::RecordInvalid)
      expect(lambda { build(:identity, last_name: nil).save! }).to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
