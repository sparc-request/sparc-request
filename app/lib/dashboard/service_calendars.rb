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

require 'action_view'

include ActionView::Helpers::FormOptionsHelper
include ActionView::Helpers::FormTagHelper
include ActionView::Helpers::NumberHelper

module Dashboard
  module ServiceCalendars
    def self.generate_visit_navigation(arm, service_request, pages, tab, portal=nil, ssr_id=nil)
      page = pages[arm.id].to_i == 0 ? 1 : pages[arm.id].to_i

      path_method = if @merged
        method(:merged_calendar_service_request_service_calendars_path)
      elsif @review
        method(:refresh_service_calendar_service_request_path)
      else
        method(:table_service_request_service_calendars_path)
      end

      returning_html = ''

      if page > 1
        returning_html += button_tag(class: 'btn btn-primary left-arrow', data: { url: path_method.call(service_request, page: page - 1, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-left')
        end
      else
        returning_html += button_tag(class: 'btn btn-primary left-arrow', disabled: true, data: { url: path_method.call(service_request, page: page - 1, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, portal: portal, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-left')
        end
      end

      returning_html += select_tag("jump_to_visit_#{arm.id}", visits_select_options(arm, pages), class: 'jump_to_visit selectpicker', url: path_method.call(service_request, pages: pages, arm_id: arm.id, tab: tab, sub_service_request_id: ssr_id, portal: portal))

      unless portal || @merged || @review
        returning_html += link_to 'Move Visit', 'javascript:void(0)', class: 'move_visits', data: { 'arm-id' => arm.id, tab: tab, 'sr-id' => service_request.id, portal: portal }
      end

      if ((page + 1) * 5) - 4 > arm.visit_count
        returning_html += button_tag(class: 'btn btn-primary right-arrow', disabled: true, data: { url: path_method.call(service_request, page: page + 1, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-right')
        end
      else
        returning_html += button_tag(class: 'btn btn-primary right-arrow', data: { url: path_method.call(service_request, page: page + 1, pages: pages, arm_id: arm.id, tab: tab, portal: portal, sub_service_request_id: ssr_id, format: :js) }) do
          tag(:span, class: 'glyphicon glyphicon-chevron-right')
        end
      end

      raw(returning_html)
    end

    # Given line_items_visit belonging to Organization A, which belongs to
    # Organization B, which belongs to Organization C, return "C > B > A".
    # This "hierarchy" stops at a process_ssrs Organization.
    def self.display_organization_hierarchy(line_items_visit)
      parent_organizations = line_items_visit.line_item.service.parents.reverse
      root = parent_organizations.find_index { |org| org.process_ssrs? } || (parent_organizations.length - 1)
      parent_organizations[0..root].map(&:abbreviation).reverse.join(' > ')
    end

    def self.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts = {})
      statuses_hidden = opts[:statuses_hidden] || %w(first_draft)
      if opts[:merged]
        arm.line_items_visits.joins(line_item: :sub_service_request).
          where.not(sub_service_requests: { status: statuses_hidden }).
          joins(line_item: :service).
          where(services: { one_time_fee: false })
      else
        (sub_service_request || service_request).line_items_visits.
          joins(:sub_service_request).
          where.not(sub_service_requests: { status: statuses_hidden }).
          joins(line_item: :service).
          where(services: { one_time_fee: false }, arm_id: arm.id)
      end.group_by do |liv|
        liv.sub_service_request.id
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
      select_tag "visits-select-for-#{arm.id}", visits_select_options(arm, page), class: 'form-control selectpicker', data: { url: url }
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

        option = ["Visits #{beginning_visit} - #{ending_visit} of #{visit_count}", page + 1, class: 'title', page: page + 1]
        arr << option

        # (beginning_visit..ending_visit).each do |y|
        if arm.visit_groups.present?
          arm.visit_groups[(beginning_visit-1)...ending_visit].each do |vg|
            arr << ["&nbsp;&nbsp; - #{vg.name}/Day #{vg.day}".html_safe, "#{vg.id}", page: page + 1] if arm.visit_groups.present?
          end
        end
      end

      options_for_select(arr, cur_page)
    end

    def self.select_row(line_items_visit, sub_service_request, portal, locked=false)
      checked        = line_items_visit.visits.all? { |v| v.research_billing_qty >= 1  }
      check_param    = checked ? 'uncheck' : 'check'
      icon           = checked ? 'glyphicon-remove' : 'glyphicon-ok'
      klass          = checked ? 'btn-danger' : 'btn-success'
      tooltip_row    = checked ? 'Uncheck Row' : 'Check Row'

      url         = "/service_calendars/toggle_calendar_row?#{check_param}=true&service_request_id=#{line_items_visit.line_item.service_request.id}&line_items_visit_id=#{line_items_visit.id}&portal=#{portal.to_s}"
      url        += "&sub_service_request_id=#{sub_service_request.id}" if sub_service_request

      content_tag(:span, '', class: "glyphicon #{icon} btn btn-xs #{klass} service-calendar-row",
                  id: "check-all-row-#{line_items_visit.id}", data: { toggle: "tooltip", animation: 'false', title: tooltip_row, url: url }, disabled: locked)
    end

    def self.select_column(visit_group, n, portal, service_request, sub_service_request)

      arm_id        = visit_group.arm_id
      # If we are in proper, we want to use service request, othewise in dashboard, we use SSR for admin study schedule
      liv_query          = sub_service_request ? { sub_service_request_id: sub_service_request.id } : { service_request_id: service_request.id }
      filtered_livs      = visit_group.line_items_visits.joins(:line_item).where(line_items: liv_query)
      checked            = filtered_livs.all? { |l| l.visits[n.to_i].research_billing_qty >= 1 }
      check_param        = checked ? 'uncheck' : 'check'
      icon               = checked ? 'glyphicon-remove' : 'glyphicon-ok'
      klass              = checked ? 'btn-danger' : 'btn-success'
      tooltip_column     = checked ? 'Uncheck Column' : 'Check Column'
      service_request_id = service_request ? service_request.id : sub_service_request.service_request.id
      url                = "/service_calendars/toggle_calendar_column?#{check_param}=true&service_request_id=#{service_request_id}&column_id=#{n + 1}&arm_id=#{arm_id}&portal=#{portal.to_s}"
      url                += "&sub_service_request_id=#{sub_service_request.id}" if sub_service_request

      content_tag(:span, '',
        role: 'button',
        class: "btn btn-xs #{klass} service-calendar-column glyphicon #{icon}",
        id: "check-all-column-#{n+1}",
        data: { toggle: "tooltip", animation: 'false', title: tooltip_column, url: url })
    end
  end
end
