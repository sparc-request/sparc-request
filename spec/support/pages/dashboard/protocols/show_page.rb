require 'rails_helper'
require 'support/pages/dashboard/notes/index_modal'
require 'support/pages/dashboard/notes/new_modal'

module Dashboard
  module Protocols
    class ShowPage < SitePrism::Page
      set_url '/dashboard/protocols{/id}'

      section :protocol_summary, '#protocol_show_information_panel' do
        element :study_notes_button, 'button', text: 'Study Notes'
        element :edit_study_info_button, 'button', text: 'Edit Study Information'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'

      section :new_notes_modal, Dashboard::Notes::NewModal, '#new-note-modal'

      section :authorized_users_panel, '#authorized-users-panel' do
        element :add_associated_user_button, 'button', text: 'Add an Authorized User'
      end

      section :add_authorized_user_modal, '#add-authorized-user-form' do
        element :select_user_field, '#authorized_user_search'
        elements :user_choices, 'div.tt-suggestion.tt-selectable'
      end

      # big panel of service requests
      section :service_requests, '#service-requests-panel' do
        element :view_consolidated_request_button, 'button.view-full-calendar-button'
        element :export_consolidated_request_link, 'a.export-consolidated-request'
        element :add_services_button, '#add-services-button'

        # actual service request panels
        sections :ssr_lists, '.service-request-info' do
          element :title, '.panel-heading .panel-title'
          element :notes_button, '.panel-heading button.notes'
          element :edit_original_button, '.panel-heading button.edit_service_request'

          sections :ssrs, 'tbody tr' do
            element :pretty_ssr_id, 'td.pretty-ssr-id'
            element :organization, 'td.rganization'
            element :status, 'td.status'
            section :actions, 'td.actions' do
              element :send_notification_select, 'button.new_notification_button'
              section :new_notification_dropdown, '.new-notification ul' do
                elements :list_items, 'li'
              end
            end
            element :send_notification_select, 'button.new_notification_button'
            element :view_ssr_button, 'button.view-sub-service-request-button'
            element :edit_ssr_button, 'button.edit_service_request'
            element :admin_edit_button, :link, 'Admin Edit'
          end
        end

        def displayed_ids
          ssr_lists.map { |l| l.root_element['data-service-request-id'] }
        end
      end

      section :new_notification_form, 'form#new_notification' do
        element :subject_field, 'input#notification_subject'
        element :message_field, 'textarea#notification_message_body'
        element :submit_button, 'button[type="submit"]'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'
      section :new_notes_modal, Dashboard::Notes::NewModal, '#new-note-modal'
    end
  end
end
