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
require 'surveyor/parser'
require 'rake'

describe "Emails", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let!(:service3)            { FactoryGirl.create(:service, organization_id: program.id, name: 'ABCD', one_time_fee: true) }
  let!(:pricing_setup)       { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map)         { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service3.id, quantity_type: "Each", quantity_minimum: 5, otf_unit_type: "Week", display_date: Time.now - 1.day, full_rate: 2000, units_per_qty_max: 20) }

  before :each do
    add_visits
  end

  describe "should render correctly for" do
    it "service providers", :js => true do
      visit_mail_for 'service provider'
      assert_notification_email_tables

      #with no changes, should not have audited information table
      page.should_not have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"

      if service_request.arms.empty?
        #no arms, should not have arm information table
        page.should_not have_xpath "//table//strong[text()='Protocol Arm Information']"
      else
        #should have appropriate arm information in table
        page.should have_xpath "//table//strong[text()='Protocol Arm Information']"
        service_request.arms.each do |arm|
          page.should have_xpath "//td[text()='#{arm.name}']/following-sibling::td[text()='#{arm.subject_count}']/following-sibling::td[text()='#{arm.visit_count}']"
        end
      end
    end

    it "users", :js => true do
      visit_mail_for 'user'
      assert_notification_email_tables

      #users should not have audited information table
      page.should_not have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
      #users should not have arm information table
      page.should_not have_xpath "//table//strong[text()='Protocol Arm Information']"
    end

    it "admins", :js => true do
      visit_mail_for 'admin'
      assert_notification_email_tables

      #admins should not have audited information table
      page.should_not have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
      #admins should not have arm information table
      page.should_not have_xpath "//table//strong[text()='Protocol Arm Information']"
    end
  end

  describe "should have audited information for SPs" do
    it "when adding a line item to the service request", :js => true do
      #Submit SR and then add line item as jug2
      Audited.audit_class.as_user(Identity.find(1)) do
        service_request.update_status('submitted')
        service_request.update_attribute(:submitted_at, Time.now)
        existing_service_ids = service_request.line_items.map(&:service_id)
        service_request.create_line_items_for_service(service: service3, optional: true, existing_service_ids: existing_service_ids, recursive_call: false)
        service_request.reload
        service_request.line_items.each do |li|
          li.update_attribute(:sub_service_request_id, sub_service_request.id)
        end
      end

      visit_mail_for 'service provider'
      assert_notification_email_tables

      #should have audited information table
      page.should have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
      page.should have_xpath "//td[text()='#{service3.name}']/following-sibling::td[text()='Added']"
    end

    it "when removing a line item from the service_request", :js => true do
      #Submit SR and then remove line item as jug2
      Audited.audit_class.as_user(Identity.find(1)) do
        service_request.update_status('submitted')
        service_request.update_attribute(:submitted_at, Time.now)
        service_request.line_items.find_by_service_id(service2.id).destroy
        service_request.line_items.reload
        service_request.reload
      end

      visit_mail_for 'service provider'
      assert_notification_email_tables

      #should have audited information table
      page.should have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
      page.should have_xpath "//td[text()='#{service2.name}']/following-sibling::td[text()='Removed']"
    end
  end

  describe "should not have arm information for service provider emails" do
    it "if there are no PPPV services on SSR and there is an audit_report", :js => true do
      #Submit SR and then remove line item as jug2
      Audited.audit_class.as_user(Identity.find(1)) do
        service_request.update_status('submitted')
        service_request.update_attribute(:submitted_at, Time.now)
        existing_service_ids = service_request.line_items.map(&:service_id)
        service_request.create_line_items_for_service(service: service3, optional: true, existing_service_ids: existing_service_ids, recursive_call: false)
        service_request.line_items.find_by_service_id(service2.id).destroy
        service_request.line_items.find_by_service_id(service.id).destroy
        service_request.line_items.reload
        service_request.reload
        service_request.line_items.each do |li|
          li.update_attribute(:sub_service_request_id, sub_service_request.id)
        end
      end
      visit_mail_for 'service provider'
      assert_notification_email_tables

      page.should_not have_xpath "//table//strong[text()='Protocol Arm Information']"
      #should have audited information table
      page.should have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
      page.should have_xpath "//td[text()='#{service2.name}']/following-sibling::td[text()='Removed']"
      page.should have_xpath "//td[text()='#{service3.name}']/following-sibling::td[text()='Added']"
      page.should have_xpath "//td[text()='#{service.name}']/following-sibling::td[text()='Removed']"
    end

    it "if there are no PPPV services on SSR and there is NO audit_report", :js => true do
      #remove line item then Submit SR
      existing_service_ids = service_request.line_items.map(&:service_id)
      service_request.create_line_items_for_service(service: service3, optional: true, existing_service_ids: existing_service_ids, recursive_call: false)
      service_request.line_items.find_by_service_id(service2.id).destroy
      service_request.line_items.find_by_service_id(service.id).destroy
      service_request.line_items.reload
      service_request.reload
      service_request.line_items.each do |li|
        li.update_attribute(:sub_service_request_id, sub_service_request.id)
      end
      service_request.update_status('submitted')
      service_request.update_attribute(:submitted_at, Time.now)

      visit_mail_for 'service provider'
      assert_notification_email_tables

      page.should_not have_xpath "//table//strong[text()='Protocol Arm Information']"
      page.should_not have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
    end
  end
end
