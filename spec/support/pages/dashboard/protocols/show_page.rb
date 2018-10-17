# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
require 'support/pages/dashboard/notes/index_modal'
require 'support/pages/dashboard/notes/form_modal'

module Dashboard
  module Protocols
    class ShowPage < SitePrism::Page
      set_url '/dashboard/protocols{/id}'

      section :protocol_summary, '#protocol_show_information_panel' do
        element :study_notes_button, 'a', text: 'Study Notes'
        element :edit_study_info_button, 'button', text: 'Edit Study Information'
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'
      section :note_form_modal, Dashboard::Notes::FormModal, '#note-form-modal'

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
        element :institution_dropdown, "button[data-id='select-pro-org-institution']"
        element :college_dropdown, "button[data-id='select-pro-org-college']"
        element :department_dropdown, "button[data-id='select-pro-org-department']"
        element :division_dropdown, "button[data-id='select-pro-org-division']"
        element :role_dropdown, "button[data-id='project_role_role']"
        element :specify_other_role, "#project_role_role_other"
        # rights radio buttons
        element :none_rights, "#project_role_project_rights_none"
        element :view_rights, "#project_role_project_rights_view"
        element :approve_rights, "#project_role_project_rights_approve"

        # generic matcher for any dropdown choices
        elements :dropdown_choices, "li a"

        element :save_button, :button, text: "Save"
        element :cancel_button, :button, text: "Close"
      end

      element :enabled_add_document_button, '#document-new:not(.disabled)', text: 'Add a Document'
      element :disabled_add_document_button, '#document-new.disabled', text: 'Add a Document'
      sections :documents, '#documents-table tbody tr' do
        element :enabled_edit_button, ".document-edit:not(.disabled)"
        element :disabled_edit_button, ".document-edit.disabled"
        element :enabled_remove_button, ".document-delete:not(.disabled)"
        element :disabled_remove_button, ".document-delete.disabled"
      end

      # modal appears after clicking Add Document Button
      section :document_modal, '.modal-dialog', text: /(Add|Edit) Document/ do
        element :x_button, "button.close"

        element :doc_type_dropdown, "button[data-id='document_doc_type']"
        element :document_upload, "input#document_document"
        element :access_dropdown, "button[data-id='org_ids']"

        # generic matcher for any dropdown choices
        elements :dropdown_choices, "li a"

        element :upload_button, 'input.btn.btn-primary'
        element :cancel_button, :button, text: "Close"
      end

      # big panel of service requests: the consolidated buttons and the
      # following :service_requests sections
      element :view_consolidated_request_button, :button, text: "View Consolidated Request"
      element :export_consolidated_request_link, :link, text: "Export Consolidated Request"
      element :add_services_button, '#add-services-button'
      # submenu options that shows after clicking either consolidated request button
      element :consolidated_request_all, "a", text: /All/
      element :consolidated_request_exclude_draft, "a", text: /Exclude Draft/

      # actual service request panels
      sections :service_requests, '#service-requests-panel' do
        element :modify_request_button, :button, text: "Modify Request"

        sections :ssrs, 'tbody tr' do
          element :send_notification_select, :button, text: "Send Notification"
          elements :recipients, '.new-notification ul li'
          element :send_notification_select, :button, text: "Send"
          element :view_button, :button, "View"
          element :edit_button, :button, "Edit"
          element :admin_edit_button, :button, "Admin Edit"
          element :complete_details_select, :button, text: "Complete Details"
        end
      end

      section :new_notification_form, 'form#new_notification' do
        element :subject_field, 'input#notification_subject'
        element :message_field, 'textarea#notification_message_body'
        element :submit_button, 'button[type="submit"]'
      end

      section :new_submission_form, 'form#new_submission' do
        element :submit_button, :link, "Create Submission"
      end

      section :index_notes_modal, Dashboard::Notes::IndexModal, '#notes-modal'

      element :view_ssr_modal, ".user-view-ssr-modal"

      # Modal displaying consolidated request
      section :consolidated_request_modal, ".modal-dialog", text: /Consolidated Request Summary/ do
        element :show_all_services_button, "label#all-services.btn"
        element :show_chosen_services_button, "label#chosen-services.btn"
      end
    end
  end
end
