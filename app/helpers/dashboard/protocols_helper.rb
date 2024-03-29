# Copyright © 2011-2022 MUSC Foundation for Research Development
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
  def protocol_id_link(protocol, access)
    if access
      link_to protocol.id, dashboard_protocol_path(protocol)
    else
      protocol.id
    end
  end

  def protocol_short_title_link(protocol, access)
    short_title = if access
      (link_to protocol.short_title, dashboard_protocol_path(protocol))
    else
      protocol.short_title
    end

    content_tag(:div, short_title) + content_tag(:div, (display_rmid_validated_protocol(protocol, Protocol.human_attribute_name(:short_title))) )
  end

  def format_protocol(protocol)
    link_to "#{protocol.type.capitalize}: #{protocol.id} - #{protocol.short_title}", dashboard_protocol_path(protocol)
  end

  def pis_display(protocol)
    content_tag(:div, class: 'd-flex flex-column align-items-start') do
      if protocol.primary_pi
        content_tag(:div, title: Protocol.human_attribute_name(:primary_pi), data: { toggle: 'tooltip', boundary: 'window' }) do
          icon('fas', 'user-circle mr-2') + protocol.primary_pi.display_name
        end
      else
        ""
      end + raw(
      protocol.principal_investigators.select{ |pi| pi != protocol.primary_pi }.map do |pi|
        content_tag(:span) do
          icon('fas', 'user mr-2') + pi.display_name
        end
      end.join())
    end
  end

  def display_requests_button(protocol, access)
    if protocol.sub_service_requests.any? && access
      link_to(display_requests_dashboard_protocol_path(protocol), remote: true, class: 'btn btn-secondary protocol-requests') do
        content_tag :span, class: 'd-flex align-items-center' do
          raw(Protocol.human_attribute_name(:requests) + content_tag(:span, protocol.sub_service_requests_count, class: 'badge badge-pill badge-c badge-light ml-2'))
        end
      end
    elsif !access
      render "dashboard/protocols/request_access_dropdown.html.haml", protocol: protocol
    end
  end

  def display_merges(protocol)
    content_tag(:div, protocol.protocol_merges.pluck(:merged_protocol_id).join(" "))
  end
end
