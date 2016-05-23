require 'rails_helper'
require 'support/pages/dashboard/notes/index_modal'

module Dashboard
  module Protocols
    class ShowPage < SitePrism::Page
      set_url '/dashboard/protocols{/id}'

      section :protocol_summary, '#protocol_show_information_panel' do
        element :study_notes_button, 'button', text: 'Study Notes'
        element :edit_study_info_button, 'button', text: 'Edit Study Information'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'

      element :enabled_add_authorized_user_button, 'button:not(.disabled)', text: 'Add an Authorized User'
      element :disabled_add_authorized_user_button, 'button.disabled', text: 'Add an Authorized User'

      # list of authorized users
      sections :authorized_users, '#associated-users-table tbody tr' do
        element :edit_button, ".edit-associated-user-button"
        element :enabled_remove_button, ".delete-associated-user-button:not(.disabled)"
        element :disabled_remove_button, ".delete-associated-user-button.disabled"
      end

      # modal appears after clicking Add Authorized User button
      section :authorized_user_modal, '.modal-dialog', text: /(Add|Edit) Authorized User/ do
        element :x_button, "button.close"

        element :select_user_field, '#authorized_user_search'
        elements :user_choices, 'div.tt-suggestion.tt-selectable'

        # these appear after selecting a user
        element :credentials_dropdown, "button[data-id='project_role_identity_attributes_credentials']"
        element :specify_other_credentials, "#project_role_identity_attributes_credentials_other"
        element :institution_dropdown, "button[data-id='project_role_identity_attributes_institution']"
        element :college_dropdown, "button[data-id='project_role_identity_attributes_college']"
        element :department_dropdown, "button[data-id='project_role_identity_attributes_department']"
        element :role_dropdown, "button[data-id='project_role_role']"
        element :specify_other_role, "#project_role_role_other"
        # rights radio buttons
        element :none_rights, "#project_role_project_rights_none"
        element :view_rights, "#project_role_project_rights_view"
        element :request_rights, "#project_role_project_rights_request"
        element :approve_rights, "#project_role_project_rights_approve"

        # generic matcher for any dropdown choices
        elements :dropdown_choices, "li a"

        element :save_button, :button, text: "Save"
        element :cancel_button, :button, text: "Close"
      end

      # big panel of service requests: the consolidated buttongs and the
      # following :service_requests sections
      element :view_consolidated_request_button, :button, text: "View Consolidated Request"
      element :export_consolidated_request_link, :link, text: "Export Consolidated Request"
      element :add_services_button, '#add-services-button'

      # actual service request panels
      sections :service_requests, '.panel-primary', text: /Service Request: \d+/ do
        element :notes_button, :button, text: "Notes"
        element :modify_request_button, :button, text: "Modify Request"

        sections :ssrs, 'tbody tr' do
          element :send_notification_select, :button, text: "Send Notification"
          elements :recipients, '.new-notification ul li'
          element :send_notification_select, :button, text: "Send"
          element :view_button, :button, "View"
          element :edit_button, :button, "Edit"
          element :admin_edit_button, :button, "Admin Edit"
        end
      end

      section :new_notification_form, 'form#new_notification' do
        element :subject_field, 'input#notification_subject'
        element :message_field, 'textarea#notification_message_body'
        element :submit_button, 'button[type="submit"]'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'

      element :view_ssr_modal, ".user-view-ssr-modal"
    end
  end
end
