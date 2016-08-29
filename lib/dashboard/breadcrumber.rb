# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class Dashboard::Breadcrumber
  include ActionView::Helpers::TagHelper

  def initialize
    clear
  end

  def clear(crumb = nil)
    if crumb
      @crumbs.delete(crumb)
    else
      @crumbs = Hash.new
    end
    self
  end

  def add_crumbs(crumbs)
    crumbs.each do |sym, value|
      add_crumb(sym, value)
    end
    self
  end

  def add_crumb(sym, value)
    @crumbs[sym] = value

    self
  end

  def breadcrumbs
    labels_and_urls = [
        protocol_label_and_url,
        edit_protocol_label_and_url,
        ssr_label_and_url,
        notifications_label_and_url
    ].compact!

    r = content_tag(:li, content_tag(:a, 'Dashboard', href: dashboard_protocols_url))
    labels_and_urls.each_with_index do |breadcrumb_array, index|
      label, url = breadcrumb_array
      if index == labels_and_urls.size - 1
        r += content_tag(:li, label, class: "active")
      else
        r += content_tag(:li, content_tag(:a, label, href: url))
      end
    end

    r.html_safe
  end

  private

  def dashboard_protocols_url
    "/dashboard/protocols"
  end

  def protocol_label_and_url
    protocol_id = @crumbs[:protocol_id]
    protocol_id ? ["(#{protocol_id}) " + Protocol.find(protocol_id).try(:short_title), "/dashboard/protocols/#{protocol_id}"] : nil
  end

  def ssr_label_and_url
    sub_service_request_id = @crumbs[:sub_service_request_id]
    sub_service_request_id ? [SubServiceRequest.find(sub_service_request_id).organization.label, "/dashboard/sub_service_requests/#{sub_service_request_id}"] : nil
  end

  def notifications_label_and_url
    @crumbs[:notifications] ? ["Notifications", "/dashboard/notifications"] : nil
  end

  def edit_protocol_label_and_url
    protocol_id = @crumbs[:edit_protocol]
    protocol_id ? ["Edit", "/dashboard/protocols/#{protocol_id}/edit"] : nil
  end
end
