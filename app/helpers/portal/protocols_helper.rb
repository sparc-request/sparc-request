# Copyright © 2011 MUSC Foundation for Research Development
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

module Portal::ProtocolsHelper

  def consolidated_request_buttons_display protocol
    if !protocol.has_first_draft_service_request? && protocol.service_requests.present?
      raw(
        content_tag( :div,
          content_tag( :button, t(:protocol_information)[:full_calendar], type: 'button', class: 'view-full-calendar-button btn btn-primary btn-sm', data: { protocol_id: protocol.id }
          )+
          link_to( t(:protocol_information)[:consolidated_request], portal_protocol_path(protocol, format: :xlsx), class: "btn btn-primary btn-sm", data: { protocol_id: protocol.id }
          ), class: "pull-right"
        )
      )
    end
  end

  def edit_protocol_button_display protocol, project_role
    if permission = project_role.can_edit?
      content_tag( :button, "Edit #{protocol.type.capitalize} Information", type: 'button', class: 'edit-protocol-information-button btn btn-warning btn-sm', data: { permission: permission.to_s, protocol_id: protocol.id })
    end
  end

  def short_title_display protocol
    truncate_string_length(protocol.short_title, 100)
  end

  def pis_display protocol
    protocol.principal_investigators.map(&:full_name).join ", "
  end

  def requests_display protocol
    ssr_ids = protocol.sub_service_requests.select(:ssr_id).map(&:ssr_id).uniq.compact

    html = '-'

    unless ssr_ids.empty?
      li = Array.new

      span = raw content_tag(:span, '', class: 'caret')
      button = raw content_tag(:button, raw('Requests  ' + span), type: 'button', class: 'btn btn-default btn-sm dropdown-toggle form-control', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
      ssr_ids.each do |r|
        li.push raw(content_tag(:li, raw(content_tag(:a, "#{protocol.id}-#{r}", href: 'javascript:;'))))
      end
      ul = raw content_tag(:ul, raw(li.join), class: 'dropdown-menu', role: 'menu')

      html = raw content_tag(:div, button + ul, class: 'btn-group')
    end

    html
  end

  def archived_button_display protocol
    content_tag( :button, (protocol.archived ? 'Unarchive' : 'Archive')+" #{protocol.type.capitalize}", type: 'button', class: 'protocol-archive-button btn btn-warning btn-sm', data: { protocol_id: protocol.id })
  end
end