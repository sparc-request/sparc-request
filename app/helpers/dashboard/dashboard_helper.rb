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

module Dashboard::DashboardHelper
  def breadcrumbs
    puts "HELPER: #{session[:breadcrumbs].inspect}"
    breads = [crumb(:protocol_id) && Protocol.find(crumb(:protocol_id)).try(:short_title),
      crumb(:sub_service_request_id) && SubServiceRequest.find(crumb(:sub_service_request_id)).try(:ssr_id),
      crumb(:notifications) && 'Notifications']
    urls   = [crumb(:protocol_id) && dashboard_protocol_path(crumb(:protocol_id)),
      crumb(:sub_service_request_id) && dashboard_sub_service_request_path(crumb(:sub_service_request_id)),
      dashboard_notifications_path]

    content_tag(:a, 'Dashboard', href: dashboard_protocols_path) + ((breads.zip(urls)).select { |b, _| !b.nil? }.map { |b, url| ' > '.html_safe + content_tag(:a, b, href: url) }.join.html_safe)
  end

  private

  def crumb(sym)
    session[:breadcrumbs] && session[:breadcrumbs][sym]
  end
end
