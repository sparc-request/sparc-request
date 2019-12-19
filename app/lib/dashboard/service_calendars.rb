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

require 'action_view'

module Dashboard
  module ServiceCalendars
    extend ActionView::Helpers::FormOptionsHelper
    extend ActionView::Helpers::FormTagHelper
    extend ActionView::Helpers::NumberHelper

    def self.generate_visit_navigation(arm, service_request, pages, tab, portal=nil, ssr_id=nil)
      page = pages[arm.id].to_i == 0 ? 1 : pages[arm.id].to_i

      path_method = if @merged
        method(:merged_calendar_service_request_service_calendars_path)
      else
        method(:table_service_request_service_calendars_path)
      end

      returning_html = ''

      if page > 1
        returning_html += button_tag(class: 'btn btn-primary left-arrow', data: { url: path_method.call(service_request, page: page - 1, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-left')
        end
      else
        returning_html += button_tag(class: 'btn btn-primary left-arrow', disabled: true, data: { url: path_method.call(service_request, page: page - 1, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-left')
        end
      end

      returning_html += select_tag("jump_to_visit_#{arm.id}", visits_select_options(arm, pages), class: 'jump_to_visit selectpicker', url: path_method.call(service_request, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id))

      unless portal || @merged || @review || service_request.protocol.locked
        returning_html += link_to 'Move Visit', 'javascript:void(0)', class: 'move_visits', data: { 'arm-id' => arm.id, tab: tab, 'sr-id' => service_request.id }
      end

      if ((page + 1) * 5) - 4 > arm.visit_count
        returning_html += button_tag(class: 'btn btn-primary right-arrow', disabled: true, data: { url: path_method.call(service_request, page: page + 1, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-right')
        end
      else
        returning_html += button_tag(class: 'btn btn-primary right-arrow', data: { url: path_method.call(service_request, page: page + 1, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-right')
        end
      end

      raw(returning_html)
    end

    def self.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts = {})
      statuses_hidden = 
        if opts[:merged] && opts[:consolidated] && !opts[:show_draft] # View Full Calendar may hide `draft` as well as `first_draft`
          %w(first_draft draft)
        elsif opts[:merged] && !opts[:consolidated] # Merged Calendar does not hide by status
          []
        else # By default don't show `first_draft`
          %w(first_draft)
        end

      # View Full Calendar
      if opts[:merged] && opts[:consolidated]
        if opts[:show_unchecked]
          arm.line_items_visits.
            eager_load(:visits, :notes).
            includes(sub_service_request: :organization, line_item: [:admin_rates, :service_request, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]]).
            where.not(sub_service_requests: { status: statuses_hidden }).
            where(services: { one_time_fee: false })
        else
          arm.line_items_visits.
            eager_load(:visits, :notes).
            includes(sub_service_request: :organization, line_item: [:admin_rates, :service_request, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]]).
            where.not(sub_service_requests: { status: statuses_hidden }).
            where(services: { one_time_fee: false }).
            where.not("research_billing_qty = 0 and insurance_billing_qty = 0 and effort_billing_qty = 0" )
        end
      else
        (sub_service_request || service_request).line_items_visits.
          eager_load(:visits, :notes).
          includes(sub_service_request: :organization, line_item: [:admin_rates, :service_request, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]]).
          where.not(sub_service_requests: { status: statuses_hidden }).
          where(services: { one_time_fee: false }, arm_id: arm.id)
      end.group_by do |liv|
        liv.sub_service_request
      end
    end

    def self.otf_line_items_to_display(service_request, sub_service_request, opts = {})
      statuses_hidden = 
        if opts[:merged] && opts[:consolidated] && !opts[:show_draft] # View Full Calendar may hide `draft` as well as `first_draft`
          %w(first_draft draft)
        elsif opts[:merged] && !opts[:consolidated] # Merged Calendar does not hide by status
          []
        else # By default don't show `first_draft`
          %w(first_draft)
        end

      (opts[:merged] && opts[:consolidated] ? service_request : (sub_service_request || service_request)).line_items.
        eager_load(:admin_rates, :notes, :service_request).
        includes(sub_service_request: :organization, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]]).
        where.not(sub_service_requests: { status: statuses_hidden }).
        where(services: { one_time_fee: true }).
        group_by do |li|
          li.sub_service_request
        end
    end

    def self.glyph_class(obj)
      count = obj.visits.where('research_billing_qty = 0 and insurance_billing_qty = 0').count
      count == 0 ? 'glyphicon-remove' : 'glyphicon-ok'
    end

    def self.display_visit_based_direct_cost_per_study(line_items_visit)
      number_to_currency(Service.cents_to_dollars(line_items_visit.direct_costs_for_visit_based_service_single_subject * (line_items_visit.subject_count || 0)))
    end

    def self.build_visits_select(arm, page, url)
      select_tag "visits-select-for-#{arm.id}", visits_select_options(arm, page), class: 'form-control selectpicker', data: { url: url, dropup_auto: 'false' }
    end

    def self.visits_select_options(arm, cur_page=1)
      per_page = Visit.per_page
      visit_count = arm.visit_count
      num_pages = (visit_count / per_page.to_f).ceil
      arr = []

      num_pages.times do |page|
        beginning_visit = (page * per_page) + 1
        ending_visit = (page * per_page + per_page)
        ending_visit = ending_visit > visit_count ? visit_count : ending_visit

        option = [I18n.t('calendars.pppv.header_fields.page_select.header', start: beginning_visit, stop: ending_visit, total: visit_count), page + 1, class: 'vg-page-header', data: { page: page + 1 }]
        arr << option

        # (beginning_visit..ending_visit).each do |y|
        if arm.visit_groups.present?
          arm.visit_groups.order(:position)[(beginning_visit-1)...ending_visit].each do |vg|
            arr << ["- #{vg.identifier}", "#{vg.id}", data: { page: page + 1 }] if arm.visit_groups.present?
          end
        end
      end

      options_for_select(arr, cur_page)
    end
  end
end
