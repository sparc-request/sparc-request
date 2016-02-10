require 'rails_helper'
module Dashboard
  module Protocols
    class ShowPage < SitePrism::Page
      set_url '/dashboard/protocols{/id}'

      element :protocol_summary, '#protocol-summary'

      # big panel of service requests
      section :service_requests, '#service-requests-panel' do
        element :view_consolidated_request_button, 'button.view-full-calendar-button'
        element :export_consolidated_request_link, 'a.export-consolidated-request'
        element :add_services_button, '#add-services-button'

        # actual service request panels
        sections :ssr_lists, '.service-request-info' do
          element :title, '.panel-title'
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
            element :admin_edit_button, 'a.edit_service_request'
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
    end
  end
end
