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

module SubServiceRequestsHelper
  # Available Options:
  # locked    - An optional condition to specify when to show a lock icon.
  #             Defaults to sub_service_request.is_locked?.
  # complete  - An optional condition to specify when to show a check icon.
  #             Defaults to sub_service_request.is_complete?.
  # context   - An optional condition to specify when to add contextual classes to the breadcrumbs.
  #             Defaults to nil (contextual classes are added, see ServicesHelper#breadcrumb_text)
  def ssr_name_display(sub_service_request, opts={})
    locked    = opts[:locked].nil?    ? sub_service_request.is_locked?    : opts[:locked]
    complete  = opts[:complete].nil?  ? sub_service_request.is_complete?  : opts[:complete]

    header  = content_tag(:strong, "(#{sub_service_request.ssr_id})", class: 'mr-1') +
                breadcrumb_text(sub_service_request.organization, context: opts[:context]).html_safe

    if complete
      header += icon('fas', 'check fa-lg mr-2')
    elsif locked
      header += icon('fas', 'lock fa-lg mr-2')
    end

    content_tag :div, header, class: 'd-flex'
  end
end
