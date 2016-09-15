# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("johnd")

  def visit_protocols_index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    page
  end

  describe 'new protocol button' do
    context 'user clicks button and selects Study from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.search_results.new_protocol_button.click
        page.search_results.new_study_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=study"
      end
    end

    context 'user clicks button and selects Project from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.search_results.new_protocol_button.click
        page.search_results.new_project_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=project"
      end
    end
  end

  describe 'Protocols list' do
    describe 'requests button and archive button' do
      describe 'user is a Super User' do
        before(:each) do
          create(:super_user, identity_id: user.id)
        end
        describe 'protocol has ssr' do
          scenario 'user should see requests button and archive button' do
            protocol = create(:study_without_validations, primary_pi: user)
            sr = create(:service_request_without_validations, protocol: protocol) 
            ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 
            page = visit_protocols_index_page

            expect(page.search_results.protocols.first).to have_requests_button
            expect(page.search_results.protocols.first).to have_archive_study_button
          end
        end
        describe 'protocol does not have ssr' do
          scenario 'user should NOT see requests button but should see archive button' do
            protocol = create(:study_without_validations, primary_pi: user)
            page = visit_protocols_index_page
            
            expect(page.search_results.protocols.first).to have_no_requests_button
            expect(page.search_results.protocols.first).to have_archive_study_button
          end
        end
      end

      describe 'user has a project role' do
        before(:each) do
          @protocol = create(:study_without_validations, primary_pi: user)
          create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol)
        end
        describe 'protocol has ssr' do
          scenario 'user should see requests button and archive button' do
            sr = create(:service_request_without_validations, protocol: @protocol) 
            ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 
            page = visit_protocols_index_page

            expect(page.search_results.protocols.first).to have_requests_button
            expect(page.search_results.protocols.first).to have_archive_study_button
          end
        end
        describe 'protocol does not have ssr' do
          scenario 'user should see requests button and archive button' do
            page = visit_protocols_index_page

            expect(page.search_results.protocols.first).to have_no_requests_button
            expect(page.search_results.protocols.first).to have_archive_study_button
          end
        end
      end
    end

    describe 'archive button' do
      context 'archived Project' do
        scenario 'User clicks button' do
          # Rights to see archive button
          create(:super_user, identity_id: user.id)
          protocol = create(:archived_project_without_validations, primary_pi: user)
          create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol)
          sr = create(:service_request_without_validations, protocol: protocol) 
          ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 

          page = visit_protocols_index_page
          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          expect(page.search_results).to have_protocols
          page.search_results.protocols.first.unarchive_project_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(false)
        end
      end

      context 'unarchived Project' do
        scenario 'User clicks button' do
           # Rights to see archive button
          create(:super_user, identity_id: user.id)
          protocol = create(:unarchived_project_without_validations, primary_pi: user)
          create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol)
          sr = create(:service_request_without_validations, protocol: protocol) 
          ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 

          page = visit_protocols_index_page
          page.search_results.protocols.first.archive_project_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(true)
        end
      end

      context 'archived Study' do
        scenario 'User clicks button' do
          create(:super_user, identity_id: user.id)
          protocol = create(:archived_study_without_validations, primary_pi: user)
          create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol)
          sr = create(:service_request_without_validations, protocol: protocol) 
          ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 

          page = visit_protocols_index_page
          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          expect(page.search_results).to have_protocols
          page.search_results.protocols.first.unarchive_study_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(false)
        end
      end

      context 'unarchived Study' do
        scenario 'User clicks button' do
          create(:super_user, identity_id: user.id)
          protocol = create(:unarchived_study_without_validations, primary_pi: user)
          create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol)
          sr = create(:service_request_without_validations, protocol: protocol) 
          ssr = create(:sub_service_request, service_request: sr, organization: create(:organization)) 

          page = visit_protocols_index_page
          page.search_results.protocols.first.archive_study_button.click

          expect(page.search_results).to have_no_protocols
          expect(protocol.reload.archived).to be(true)
        end
      end
    end
  end
end
