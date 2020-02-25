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

module ServicesHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def cpt_code_text(service)
    unless service.cpt_code.blank?
      content_tag(:div, class: 'w-100') do
        content_tag(:span, "#{t(:catalog_manager)[:organization_form][:cpt_code]}: ") + content_tag(:span, service.cpt_code)
      end
    end
  end

  def eap_id_text(service)
    unless service.eap_id.blank?
      content_tag(:div, class: 'w-100') do
        content_tag(:span, "#{t(:catalog_manager)[:organization_form][:eap_id]}: ") + content_tag(:span, service.eap_id)
      end
    end
  end

  def service_pricing_text(service)
    if current_user.present?
      rates = service.displayed_pricing_map.true_rate_hash

      if @shard != current_user.shard_identifier
        rates.each { |type, rate| rates[type] = rate * Service.external_charge_rate }
      end

      content_tag(:div, class: 'w-100 d-flex flex-wrap') do
        content_tag(:div, class: 'w-100') do
          content_tag(:span, "#{Service::RATE_TYPES[:full]}: ") + "$#{'%.2f' % (rates[:full]/100)}"
        end +
        content_tag(:div, class: 'w-25') do
          content_tag(:span, "#{Service::RATE_TYPES[:federal].gsub(' Rate', '')}: ") + "$#{'%.2f' % (rates[:federal]/100)}"
        end +
        content_tag(:div, class: 'w-25') do
          content_tag(:span, "#{Service::RATE_TYPES[:corporate].gsub(' Rate', '')}: ") + "$#{'%.2f' % (rates[:corporate]/100)}"
        end +
        content_tag(:div, class: 'w-25') do
          content_tag(:span, "#{Service::RATE_TYPES[:member].gsub(' Rate', '')}: ") + "$#{'%.2f' % (rates[:member]/100)}"
        end +
        content_tag(:div, class: 'w-25') do
          content_tag(:span, "#{Service::RATE_TYPES[:other].gsub(' Rate', '')}: ") + "$#{'%.2f' % (rates[:other]/100)}"
        end
      end
    end
  end

  def breadcrumb_text(item, opts={})
    if (orgs = item.is_a?(Service) ? item.organization_hierarchy(false, true, false, true) : item.organization_hierarchy(true, true, false, true)).any?
      content_tag :div, class: 'd-inline-flex flex-wrap align-items-center' do
        breadcrumb = []
        orgs.each do |parent|
          breadcrumb << content_tag(:span, "#{parent.abbreviation}", class: opts[:context] == false ? "" : "text-#{parent.type.downcase}")
          breadcrumb << icon('fas', 'caret-right mx-1')
        end
        breadcrumb.pop
        breadcrumb.join.html_safe
      end
    end
  end
end
