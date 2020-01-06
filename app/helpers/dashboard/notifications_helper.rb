# Copyright © 2011-2019 MUSC Foundation for Research Development
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

module Dashboard::NotificationsHelper
  def notification_subject_line(notification)
    protocol = notification.sub_service_request_id.blank? ? '' : "[#{notification.sub_service_request.display_id}] - "
    subject = notification.subject.present? ? notification.subject : t(:dashboard)[:messages][:index][:no_subject]
    body    = notification.messages.length > 0 ? notification.messages.last.body : ""

    if controller_name == 'notifications'
      content_tag :div, class: 'd-flex flex-column' do
        content_tag(:span, protocol + truncate_string_length(subject), class: "text-primary") +
        content_tag(:span, ' - ' + truncate_string_length(body), class: "text-muted")
      end
    else
      link_to protocol + truncate_string_length(subject), dashboard_protocol_path(notification.sub_service_request.protocol_id), target: :_blank
    end
  end

  def notification_time_display(notification)
    unless notification.messages.empty?
      format_datetime(notification.messages.last.created_at, html: true)
    else
      format_datetime(notification.updated_at, html: true)
    end
  end

  def display_authorized_user(project_role, ssr)
    content_tag :span do
      raw(
        content_tag(:strong, display_user_role(project_role), class: 'mr-2') + "#{project_role.identity.full_name}" + 
        (project_role.identity_id == ssr.service_requester_id ? content_tag(:small, content_tag(:em, t('dashboard.notifications.table.requester')), class: 'text-primary ml-1') : '')
      )
    end
  end

  def display_service_provider(service_provider, ssr)
    content_tag :span do
      raw(
        service_provider.identity.full_name +
        (service_provider.identity_id == ssr.owner_id ? content_tag(:small, content_tag(:em, t('dashboard.notifications.table.owner')), class: 'text-primary ml-1') : '')
      )
    end
  end
end
