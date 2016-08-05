require 'rails_helper'

RSpec.describe Notifier do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let(:service3)           { create(:service,
                                    organization_id: program.id,
                                    name: 'ABCD',
                                    one_time_fee: true) }
  let(:pricing_setup)     { create(:pricing_setup,
                                    organization_id: program.id,
                                    display_date: Time.now - 1.day,
                                    federal: 50,
                                    corporate: 50,
                                    other: 50,
                                    member: 50,
                                    college_rate_type: 'federal',
                                    federal_rate_type: 'federal',
                                    industry_rate_type: 'federal',
                                    investigator_rate_type: 'federal',
                                    internal_rate_type: 'federal',
                                    foundation_rate_type: 'federal') }
  let(:pricing_map)       { create(:pricing_map,
                                    unit_minimum: 1,
                                    unit_factor: 1,
                                    service: service3,
                                    quantity_type: 'Each',
                                    quantity_minimum: 5,
                                    otf_unit_type: 'Week',
                                    display_date: Time.now - 1.day,
                                    full_rate: 2000,
                                    units_per_qty_max: 20) }
  let(:identity)          { Identity.first }
  let(:organization)      { Organization.first }
  let(:non_service_provider_org)  { create(:organization, name: 'BLAH', process_ssrs: 0, is_available: 1) }
  let(:service_provider)  { create(:service_provider,
                                    identity: identity,
                                    organization: organization,
                                    service: service3) }
  let!(:non_service_provider_ssr) { create(:sub_service_request, ssr_id: "0004", service_request_id: service_request.id, organization_id: non_service_provider_org.id, status: "draft", org_tree_display: "SCTR1/BLAH")}

  before { add_visits }

  describe 'body content' do

    let(:previously_submitted_at) { service_request.submitted_at.nil? ? Time.now.utc : service_request.submitted_at.utc }
    let(:audit)                   { sub_service_request.audit_report(identity,
                                                                      previously_submitted_at,
                                                                      Time.now.utc) }
    context 'service providers' do
      let(:xls)                     { Array.new }
      let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        audit) }
      it 'should render default tables' do
        assert_notification_email_tables
      end

      it 'should not have audited information table' do
        expect(mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
      end

      it 'should have audited information table' do
        expect(mail).to have_xpath("//table//strong[text()='Protocol Arm Information']")
        service_request.arms.each do |arm|
          expect(mail).to have_xpath("//td[text()='#{arm.name}']/following-sibling::td[text()='#{arm.subject_count}']/following-sibling::td[text()='#{arm.visit_count}']")
        end
      end

      context 'when protocol has selected for epic' do
        before do
          service_request.protocol.update_attribute(:selected_for_epic, true)
        end

        it 'should show epic column' do
          expect(mail.body).to have_xpath "//table//strong[text()='User Information']"
          expect(mail.body).to have_xpath "//th[text()='User Name']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='Epic Access']"
          service_request.protocol.project_roles.each do |role|
            if identity.id == role.identity.id
              requester_flag = " (Requester)"
            else
              requester_flag = ""
            end
            user_epic_access = role.epic_access == false ? "No" : "Yes"
            expect(mail.body).to have_xpath "//td[text()='#{role.identity.full_name}']/following-sibling::td[text()='#{role.identity.email}']/following-sibling::td[text()='#{role.role.upcase}#{requester_flag}']/following-sibling::td[text()='#{user_epic_access}']"
          end
        end
      end

      context 'when there are no PPPV services on SubServiceRequest and there is no AuditReport' do

        before do
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
        end

        let(:mail) { Notifier.notify_service_provider(service_provider,
                                                      service_request,
                                                      xls,
                                                      identity,
                                                      audit) }

        it 'should not have Protocol Arm information' do
          assert_notification_email_tables
          expect(mail).not_to have_xpath "//table//strong[text()='Protocol Arm Information']"
          expect(mail).not_to have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
        end
      end

      context 'when there are no PPPV services on SSR and there is an AuditReport' do

        before do
          Audited.audit_class.as_user(Identity.first) do
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
        end

        let(:mail) { Notifier.notify_service_provider(service_provider,
                                                      service_request,
                                                      xls,
                                                      identity,
                                                      audit) }

        it 'should have audited information table' do
          assert_notification_email_tables
          expect(mail).to have_xpath "//th[text()='Service']/following-sibling::th[text()='Action']"
          expect(mail).to have_xpath "//td[text()='#{service2.name}']/following-sibling::td[text()='Removed']"
          expect(mail).to have_xpath "//td[text()='#{service3.name}']/following-sibling::td[text()='Added']"
          expect(mail).to have_xpath "//td[text()='#{service.name}']/following-sibling::td[text()='Removed']"
        end
      end

      context 'when adding a LineItem to the ServiceRequest' do

        before do
          Audited.audit_class.as_user(identity) do
            service_request.update_status('submitted')
            service_request.update_attribute(:submitted_at, Time.now)
            existing_service_ids = service_request.line_items.map(&:service_id)
            service_request.create_line_items_for_service(service: service3, optional: true, existing_service_ids: existing_service_ids, recursive_call: false)
            service_request.line_items.each do |li|
              li.update_attribute(:sub_service_request_id, sub_service_request.id)
            end
            service_request.line_items.reload
            service_request.reload
          end
        end

        let(:mail) { Notifier.notify_service_provider(service_provider,
                                                      service_request,
                                                      xls,
                                                      identity,
                                                      audit) }

        it 'should have audited information for ServiceProviders' do
          assert_notification_email_tables
          expect(mail).to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
          expect(mail).to have_xpath("//td[text()='#{service3.name}']/following-sibling::td[text()='Added']")
        end
      end

      context 'when removing a LineItem from the ServiceRequest' do

        before do
          Audited.audit_class.as_user(identity) do
            service_request.update_status('submitted')
            service_request.update_attribute(:submitted_at, Time.now)
            service_request.line_items.find_by_service_id(service.id).destroy
            service_request.line_items.reload
            service_request.reload
          end
        end

        let(:mail) { Notifier.notify_service_provider(service_provider,
                                                      service_request,
                                                      xls,
                                                      identity,
                                                      audit) }

        it 'should have audited information for ServiceProviders' do
          assert_notification_email_tables
          expect(mail).to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
          expect(mail).to have_xpath("//td[text()='#{service.name}']/following-sibling::td[text()='Removed']")
        end
        it "should have the correct subject" do
          expect(mail).to have_subject("#{service_request.protocol.id} - [Test - EMAIL TO glennj@musc.edu] SPARC Request service request")
        end
      end
    end

    context 'users' do
      let(:xls)                     { ' ' }
      let(:project_role)            { service_request.protocol.project_roles.select{ |role| role.project_rights != 'none' && !role.identity.email.blank? }.first }
      let(:approval)                { service_request.approvals.create }
      let(:mail)                    { Notifier.notify_user(project_role,
                                                            service_request,
                                                            xls,
                                                            approval,
                                                            identity) }
      it 'should have Arm information table' do
        expect(mail.body.parts.first.body).to have_xpath("//table//strong[text()='Protocol Arm Information']")
      end

      it 'should show all SSRs in the SR table' do
        sub_service_request.update_attribute(:org_tree_display, "SCTR1/Office of Biomedical Informatics")
        expect(mail).to have_xpath "//table//strong[text()='Service Request Information']"
        expect(mail).to have_xpath "//th[text()='SRID']/following-sibling::th[text()='Organization']/following-sibling::th[text()='Status']"
        service_request.protocol.sub_service_requests.each do |ssr|
          status = AVAILABLE_STATUSES[ssr.status]
          expect(mail.body.parts.first.body).to have_xpath "//td[text()='#{ssr.display_id}']/following-sibling::td[text()='#{ssr.org_tree_display}']/following-sibling::td[text()='#{status}']"
        end
      end
    end
  end
end
