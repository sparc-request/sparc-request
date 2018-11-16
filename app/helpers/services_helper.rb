# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

module ServicesHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def cpt_code_text(service)
    content_tag(:span, class: 'col-sm-3 no-padding') do
      content_tag(:strong, "CPT Code: ") + (service.cpt_code.blank? ? "N/A" : service.cpt_code)
    end
  end

  def eap_id_text(service)
    content_tag(:span, class: 'col-sm-3 no-padding') do
      content_tag(:strong, "EAP ID: ") + (service.eap_id.blank? ? "N/A" : service.eap_id)
    end
  end

  def service_pricing_text(service)
    if current_user.present?
      content_tag(:span, class: 'service-pricing-container') do
        raw(service.displayed_pricing_map.true_rate_hash.map do |label, value|
          content_tag(:span, class: ['no-padding', label == :full ? 'col-sm-12' : 'col-sm-3']) do
            content_tag(:strong, "#{Service::RATE_TYPES[label]}: ") + "$#{'%.2f' % (value/100)}"
          end
        end.join(''))
      end
    end
  end
end
