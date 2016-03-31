require 'rails_helper'
require 'support/pages/dashboard/notes/index_modal'
require 'support/pages/dashboard/notes/new_modal'

module Dashboard
  module Protocols
    class IndexPage < SitePrism::Page
      set_url '/dashboard/protocols'

      element :new_protocol_button, 'button', text: 'New Protocol'
      element :new_study_option, 'a', text: 'New Study'
      element :new_project_option, 'a', text: 'New Project'

      def new_protocol(protocol_type)
        new_protocol_button.click
        new_protocol_options.select { |opt| opt.text == "New #{protocol_type}" }.first.click
      end

      section :filter_protocols, '.panel', text: 'Filter Protocols' do
        element :save_link, 'a', text: 'Save'
        element :reset_link, 'a', text: 'Reset'
        element :archived_checkbox, :field, 'Archived'
        element :search_field, :field, 'Search'
        element :status_select, 'div.status-select button'
        elements :status_options, 'div.status-select li'
        element :my_protocols_checkbox, :field, 'My Protocols'
        element :my_admin_organizations_checkbox, :field, 'My Admin Organizations'
        element :core_select, 'div.core-select button'
        elements :core_options, 'div.core-select li'
        element :apply_filter_button, :button, 'Filter'

        def select_status(status)
          status_select.click
          wait_for_status_options
          status_options.select { |so| so.text == status.capitalize }.first.click
          page.find('body').click # seems like Capybara page is available in this context
          wait_until_status_options_invisible
        end

        def select_core(core)
          core_select.click
          wait_for_core_options
          core_options.select { |so| so.text == core.capitalize }.first.click
          page.find('body').click # seems like Capybara page is available in this context
          wait_until_core_options_invisible
        end

        def selected_core
          core_select['title']
        end
      end
      
      section :recently_saved_filters, '.panel', text: 'Recently Saved Filters' do
        elements :filters, 'li a'
      end

      section :search_results, '.panel', text: /(Displaying all [\d]+ protocols)|(Displaying protocols)|(Displaying 1 protocol)|(No protocols found)/ do
        sections :protocols, 'tbody tr.protocols_index_row' do
          element :requests_button, :button, 'Requests'
          element :archive_project_button, :button, 'Archive Project'
          element :unarchive_project_button, :button, 'Unarchive Project'
          element :archive_study_button, :button, 'Archive Study'
          element :unarchive_study_button, :button, 'Unarchive Study'
        end
      end

      section :requests_modal, '#requests-modal' do
        element :title, '.modal-header h4'
        sections :service_requests, '.panel.service-request-info' do
          element :header, '.panel-heading .panel-title'
          element :notes_button, :button, 'Notes'
          element :edit_original_button, :button, 'Edit Original'
          sections :sub_service_requests, 'tbody tr' do
            element :pretty_ssr_id, 'td.pretty-ssr-id'
            element :organization, 'td.organization'
            element :status, 'td.status'
            element :view_ssr_button, :button, 'View SSR'
            element :edit_ssr_button, :button, 'Edit SSR'
            element :admin_edit_button, :link, 'Admin Edit'
          end
        end
      end

      section :filter_form_modal, 'form.new_protocol_filter', text: "Choose a name for your search." do
        element :name_field, '#protocol_filter_search_name'
        element :save_button, 'input.btn[value="Save"]'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'

      section :new_notes_modal, Dashboard::Notes::NewModal, '#new-note-modal'
    end
  end
end
