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

require "rails_helper"
require "support/pages/dashboard/notes/index_modal"

module Dashboard
  module Protocols
    class IndexPage < SitePrism::Page
      set_url "/dashboard/protocols"

      # Pane on the left of page with 'Filter Protocols' as header
      section :filter_protocols, ".panel", text: "Filter Protocols" do
        element :save_link, "a", text: "Save"
        element :reset_link, "a", text: "Reset"

        element :search_field, :field, "Search"
        element :archived_checkbox, :field, "Archived"
        element :status_select, "div.status-select button"
        elements :status_options, "div.status-select li"
        element :core_select, "div.core-select button"
        elements :core_options, "div.core-select li"
        
        # these appear if user is an admin
        element :owner_select, "div.owner-select button"
        elements :owner_options, "div.owner-select li"
        element :my_protocols_checkbox, ".identity-protocols input"
        element :my_admin_organizations_checkbox, ".admin-protocols input"

        element :apply_filter_button, :button, "Filter"

        # select a status from :status_select by text
        def select_status(*statuses)
          status_select.click
          wait_for_status_options
          statuses.each do |status|
            status_options(text: /\A#{status}\Z/).first.click
          end
          page.find("body").click # seems like Capybara page is available in this context
          wait_until_status_options_invisible
        end

        # select a core for :core_select by core
        def select_core(*cores)
          core_select.click
          wait_for_core_options
          cores.each do |core|
            core_options(text: /\A#{core}\Z/).first.click
          end
          page.find("body").click # seems like Capybara page is available in this context
          wait_until_core_options_invisible
        end

        # select an owner (service provider) :owner_select by text
        def select_owner(*owners)
          owner_select.click
          wait_for_owner_options
          owners.each do |owner|
            owner_options(text: /\A#{owner}\Z/).first.click
          end
          page.find("body").click
          wait_until_owner_options_invisible
        end
      end

      # appears when the save link in the Filter Protocols pane is clicked
      section :filter_form_modal, ".modal-dialog", text: "Choose a name for your search." do
        element :name_field, :field, "Name"
        element :save_button, "input[type='submit']"
      end

      # main content of page with header 'Protocols'
      section :search_results, ".panel", text: /(Displaying all [\d]+ protocols)|(Displaying protocols)|(Displaying 1 protocol)|(No protocols found)/ do
        element :new_protocol_button, "button", text: "New Protocol"
        element :new_study_option, "a", text: "New Study"
        element :new_project_option, "a", text: "New Project"

        # rows of table
        sections :protocols, "tbody tr.protocols_index_row" do
          element :requests_button, :button, "Requests"
          element :archive_project_button, :button, "Archive Project"
          element :unarchive_project_button, :button, "Unarchive Project"
          element :archive_study_button, :button, "Archive Study"
          element :unarchive_study_button, :button, "Unarchive Study"
        end
      end

      # will appear under Filter Protocols pane, if user has any
      section :recently_saved_filters, ".panel", text: "Recently Saved Filters" do
        elements :filters, "li a"
      end

      # appears after clicking Requests button in Search Results table
      section :requests_modal, "#requests-modal" do
        # the collection of all blue-header'd tables titled by 'Service Request: <digits>''
        sections :service_requests, ".panel", text: /Service Request: [\d]+/ do
          element :notes_button, :button, "Notes"
          element :modify_request_button, :button, "Modify Request"

          sections :sub_service_requests, "tbody tr" do
            element :view_button, :button, "View"
            element :edit_button, :button, "Edit"
            element :admin_edit_button, :button, "Admin Edit"
          end
        end
      end

      # appears after clicking View SSR button in requests modal
      element :view_ssr_modal, ".modal-dialog.user-view-ssr-modal"

      # appears after clicking Notes button in requests modal
      section :index_notes_modal, Dashboard::Notes::IndexModal, "#notes-modal"
    end
  end
end
