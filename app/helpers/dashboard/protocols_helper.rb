# Copyright © 2011-2016 MUSC Foundation for Research Development
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

module Dashboard::ProtocolsHelper

  def consolidated_request_buttons_display(protocol)
    if !protocol.has_first_draft_service_request? && protocol.service_requests.present?
      raw(
        content_tag( :div,
          content_tag( :button, t(:dashboard)[:protocols][:service_requests][:view_consolidated], type: 'button', class: 'view-full-calendar-button btn btn-primary btn-sm', data: { protocol_id: protocol.id }
          )+
          link_to( t(:dashboard)[:protocols][:service_requests][:export_consolidated], dashboard_protocol_path(protocol, format: :xlsx), class: "btn btn-primary btn-sm", data: { protocol_id: protocol.id }
          ), class: "export-consolidated-request"
        )
      )
    end
  end

  def edit_protocol_button_display(protocol, permission_to_edit)
    if permission_to_edit
      content_tag( :button, t(:dashboard)[:protocols][:summary][:edit1] + protocol.type.capitalize + t(:dashboard)[:protocols][:summary][:edit2], type: 'button', class: 'edit-protocol-information-button btn btn-warning btn-sm', data: { permission: permission_to_edit.to_s, protocol_id: protocol.id })
    end
  end

  def short_title_display(protocol)
    truncate_string_length(protocol.short_title, 100)
  end

  def pis_display(protocol)
    protocol.principal_investigators.map(&:full_name).join ", "
  end

  def display_requests_button(protocol, admin_protocols, current_user)
    if protocol.sub_service_requests.any? && (protocol.project_roles.where(identity: current_user).any? || admin_protocols.try(:include?, protocol.id))
      content_tag( :button, t(:dashboard)[:protocols][:table][:requests], type: 'button', class: 'requests_display_link btn btn-default btn-sm' )
    end
  end

  def display_archive_button(protocol, admin_protocols, current_user)
    if !protocol.project_roles.find_by(identity: current_user).nil? || admin_protocols.try(:include?, protocol.id)
      content_tag( :button, (protocol.archived ? t(:dashboard)[:protocols][:table][:unarchive] : t(:dashboard)[:protocols][:table][:archive])+" #{protocol.type.capitalize}", type: 'button', class: 'protocol-archive-button btn btn-warning btn-sm' )
    end
  end
end
