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

module Portal::ApplicationHelper
  
  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def is_num?(str)
    Float(str)
  rescue ArgumentError
    false
  else
    true
  end

  def is_whole_number?(number)
    number.to_i == number ? true : false
  end

  def two_decimal_places(num)
    sprintf('%0.2f', num.to_f.round(2)) rescue nil
  end

  def application_title

  end

  def cents_to_dollars(cost)
    cost / 100.00 rescue nil
  end

  def boolean_to_image(boolean)
    case boolean
    when true then image_tag('accept.png')
    when false then image_tag('cancel.png')
    else nil
    end
  end

  # def document_download_link(link)
  #   link + "?alf_ticket=" + Document.ticket(Alfresco::Document::ALFRESCO_USER, Alfresco::Document::ALFRESCO_PASSWORD)
  # end

  def cancel_or_reset_changes(controller)
    case controller.controller_name
    when 'projects' then link_to "Cancel", root_path
    else link_to "Reset Changes", service_request_related_service_request_path, :anchor => '#project'
    end
  end

  def hidden_ssr_id(controller)
    controller.controller_name == 'related_service_requests' ? hidden_field_tag('ssr_id', params[:id]) : ''
  end

  def hidden_friendly_id(controller)
    controller.controller_name == 'related_service_requests' ? hidden_field_tag('friendly_id', @service_request.friendly_id) : ''
  end

  def pretty_ssr_id(project, ssr)
    pre_id = project.try(:id)
    ssr_id = ssr.try(:ssr_id)

    "#{pre_id}-#{ssr_id}"
  end

  def pretty_submitted_at(entity)
    entity.submitted_at.to_time.strftime("%D") rescue "Not Yet Submitted"
  end

  def display_user_role(user)
    user.role == 'other' ? user.role_other.humanize : user.role.humanize
  end
end
