# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

module ServiceRequestsHelper
  def organization_name_display(organization, locked, has_children)
    raw(if locked
      icon('fas', 'lock mr-3')
    elsif has_children
      icon('fas', 'caret-down mr-3')
    else
      ""
    end + content_tag(:span, organization.name, class: 'flex-fill text-left'))
  end

  def ssr_name_display(sub_service_request)
    header = content_tag(:strong, "(#{sub_service_request.ssr_id})", class: 'mr-2')

    if sub_service_request.is_complete?
      header += icon('fas', 'check fa-lg mr-2')
    elsif sub_service_request.is_locked?
      header += icon('fas', 'lock fa-lg mr-2')
    end

    content_tag :span, (header + sub_service_request.organization.name)
  end

  def service_name_display(line_item)
    ssr = line_item.sub_service_request
    service = line_item.service
    display_name = service.display_service_name + (ssr.ssr_id ? " (#{ssr.ssr_id})" : "")

    if ssr.can_be_edited?
      link_to(display_name, "javascript:void(0)", class: "service service-#{service.id} btn btn-default", data: { id: service.id })
    else
      link_to "<i class='glyphicon glyphicon-lock text-danger'></i> #{display_name}".html_safe, "javascript:void(0)", class: "text-danger list-group-item-danger service service-#{service.id} btn btn-default list-group-item", data: { id: service.id }
    end
  end

  def save_as_draft_button(service_request)
    content_tag :button, t('proper.navigation.bottom.save_as_draft'), type: 'button', id: 'saveAsDraft', class: 'btn btn-lg btn-outline-warning'
  end
end
