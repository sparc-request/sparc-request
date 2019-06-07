# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe "User saves a filter", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution  = create(:institution)
    @provider     = create(:provider, parent: @institution)
    @program      = create(:program, parent: @provider)
    @organization = create(:core, parent: @program, name: "Corey's House")
    @protocol     = create(:study_without_validations, primary_pi: jug2)
    @sr           = create(:service_request_without_validations, protocol: @protocol)
    @ssr          = create(:sub_service_request, service_request: @sr, organization: @organization, protocol: @protocol)
  end

  context "as a general user" do
    before :each do
      visit dashboard_protocols_path
      wait_for_javascript_to_finish
    end

    context "and clicks save" do
      before :each do
        find("#filterrific_show_archived").click
        bootstrap_multiselect("#filterrific_with_status", ["Complete", "Active"])
        bootstrap_multiselect("#filterrific_with_organization", [@organization.name])
        find("#save_filters_link").click
        wait_for_javascript_to_finish
      end

      scenario "and sees the save filter modal" do
        expect(page).to have_selector("#new_protocol_filter")
      end

      context "and saves the filter" do
        before :each do
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        scenario "and sees the saved filter" do
          expect(ProtocolFilter.count).to eq(1)

          filter = ProtocolFilter.first

          expect(filter.show_archived).to eq(true)
          expect(filter.with_status).to eq(['ctrc_approved', 'complete'])
          expect(filter.with_organization).to eq(["#{@organization.id}"])
        end
      end
    end
  end

  context "as an admin" do
    before :each do
      create(:service_provider, identity: jug2, organization: @organization)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish
    end

    context "and clicks save" do
      before :each do
        find("#filterrific_show_archived").click
        bootstrap_multiselect("#filterrific_with_status", ["Complete", "Active"])
        bootstrap_multiselect("#filterrific_with_organization", [@organization.name])
        bootstrap_multiselect("#filterrific_with_owner", [jug2.last_name_first])
        find("#save_filters_link").click
        wait_for_javascript_to_finish
      end

      scenario "and sees the save filter modal" do
        expect(page).to have_selector("#new_protocol_filter")
      end

      context "and saves the filter" do
        before :each do
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        scenario "and sees the saved filter" do
          expect(ProtocolFilter.count).to eq(1)

          filter = ProtocolFilter.first

          expect(filter.show_archived).to eq(true)
          expect(filter.with_status).to eq(['ctrc_approved', 'complete'])
          expect(filter.with_organization).to eq(["#{@organization.id}"])
          expect(filter.with_owner).to eq(["#{jug2.id}"])
        end
      end
    end
  end
end
