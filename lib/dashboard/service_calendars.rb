require 'action_view'

include ActionView::Helpers::FormOptionsHelper
include ActionView::Helpers::FormTagHelper
include ActionView::Helpers::NumberHelper

module Dashboard
  module ServiceCalendars
    def self.generate_visit_header_row(arm, service_request, page, sub_service_request, portal = nil)
      base_url = "/dashboard/service_requests/#{service_request.id}/service_calendars"
      day_url = base_url + '/set_day'
      window_before_url = base_url + '/set_window_before'
      window_after_url = base_url + '/set_window_after'
      page = page == 0 ? 1 : page
      beginning_visit = (page * 5) - 4
      ending_visit = (page * 5) > arm.visit_count ? arm.visit_count : (page * 5)
      returning_html = ''
      line_items_visits = arm.line_items_visits
      visit_groups = arm.visit_groups

      (beginning_visit .. ending_visit).each do |n|
        visit_name = visit_groups[n - 1].name || "Visit #{n}"
        visit_group = visit_groups[n - 1]

        if params[:action] == 'review' || params[:action] == 'show' || params[:action] == 'refresh_service_calendar'
          returning_html += content_tag(:th, content_tag(:span, visit_name), width: 60, class: 'visit_number')
        elsif @merged
          returning_html += content_tag(:th,
                                        ((USE_EPIC) ?
                                            label_tag('decrement', t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                                                label_tag('day', t(:calendar_page)[:headers][:day]) +
                                                label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                                                tag(:br) +
                                                content_tag(:span, visit_group.window_before, style: 'display:inline-block;width:25px;') +
                                                content_tag(:span, visit_group.day, style: 'display:inline-block;width:25px;') +
                                                content_tag(:span, visit_group.window_after, style: 'display:inline-block;width:25px;') +
                                                tag(:br) : label_tag('')) +
                                            content_tag(:span, visit_name, style: 'display:inline-block;width:75px;') +
                                            tag(:br), class: 'col-lg-1')
        elsif @tab != 'template'
          returning_html += content_tag(:span,
                                        ((USE_EPIC) ?
                                            label_tag('decrement', t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                                                label_tag('day', t(:calendar_page)[:headers][:day]) +
                                                label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                                                tag(:br) +
                                                text_field_tag('window_before', visit_group.window_before, class: "visit_window visit_window_before position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-before' => visit_group.window_before, update: "#{window_before_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                text_field_tag('day', visit_group.day, class: "visit_day position_#{n}", maxlength: 4, size: 4, :'data-position' => n - 1, :'data-day' => visit_group.day, update: "#{day_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                text_field_tag('window_after', visit_group.window_after, class: "visit_window visit_window_after position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-after' => visit_group.window_after, update: "#{window_after_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                tag(:br)
                                        : label_tag('')) +
                                            text_field_tag("arm_#{arm.id}_visit_name_#{n}", visit_name, class: 'visit_name', size: 10, :'data-arm_id' => arm.id, :'data-visit_position' => n - 1, :'data-service_request_id' => service_request.id) +
                                            tag(:br))
        else
          if sub_service_request
            filtered_line_items_visits = line_items_visits.select { |x| x.line_item.sub_service_request_id == sub_service_request.id }
          else
            filtered_line_items_visits = line_items_visits.select { |x| x.line_item.service_request_id == service_request.id }
          end
          checked = filtered_line_items_visits.each.map { |l| l.visits[n.to_i-1].research_billing_qty >= 1 ? true : false }.all?
          action = checked ? 'unselect_calendar_column' : 'select_calendar_column'
          icon = checked ? 'ui-icon-close' : 'ui-icon-check'
          returning_html += content_tag(:span,
                                        ((USE_EPIC) ?
                                            label_tag('decrement', t(:calendar_page)[:headers][:decrement], class: 'decrement_days') +
                                                label_tag('day', t(:calendar_page)[:headers][:day]) +
                                                label_tag('increment', t(:calendar_page)[:headers][:increment], class: 'increment_days') +
                                                tag(:br) +
                                                text_field_tag('window_before', visit_group.window_before, class: "visit_window visit_window_before position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-before' => visit_group.window_before, update: "#{window_before_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                text_field_tag('day', visit_group.day, class: "visit_day position_#{n}", maxlength: 4, size: 4, :'data-position' => n - 1, :'data-day' => visit_group.day, update: "#{day_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                text_field_tag('window_after', visit_group.window_after, class: "visit_window visit_window_after position_#{n} input_small", size: 1, :'data-position' => n - 1, :'data-window-after' => visit_group.window_after, update: "#{window_after_url}?arm_id=#{arm.id}&portal=#{portal}") +
                                                tag(:br)
                                        : label_tag('')) +
                                            text_field_tag("arm_#{arm.id}_visit_name_#{n}", visit_name, class: 'visit_name', size: 10, :'data-arm_id' => arm.id, :'data-visit_position' => n - 1, :'data-service_request_id' => service_request.id) +
                                            tag(:br) +
                                            link_to((content_tag(:span, '', class: "ui-button-icon-primary ui-icon #{icon}") + content_tag(:span, 'Check All', class: 'ui-button-text')),
                                                    "/dashboard/service_requests/#{service_request.id}/#{action}/#{n}/#{arm.id}?portal=#{portal}",
                                                    remote: true, role: 'button', class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only', id: "check_all_column_#{n}", data: (visit_group.any_visit_quantities_customized?(service_request) ? {confirm: 'This will reset custom values for this column, do you wish to continue?'} : nil)),
                                        width: 60, class: 'visit_number')
        end
      end

      ((page * 5) - arm.visit_count).times do
        returning_html += content_tag(:th, '', class: 'visit_number col-lg-1')
      end

      raw(returning_html)
    end

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

    # this was extracted mostly verbatum from a partial
    # TODO understand
    def self.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts={})
      merged = opts[:merged]
      portal = opts[:portal]
      grouped_livs = Hash.new

      if merged
        arm.service_list.each do |_, value| # get only per patient/per visit services and group them
          livs = Array.new
          arm.line_items_visits.each do |line_items_visit|
            line_item = line_items_visit.line_item
            next unless value[:line_items].include?(line_item)
            if %w(first_draft draft).include?(line_item.service_request.status)
              next if portal
              next if service_request != line_item.service_request
            end
            livs << line_items_visit
          end
          grouped_livs[value[:name]] = livs unless livs.empty?
        end
      else
        service_request.service_list(false).each do |_, value| # get only per patient/per visit services and group them
          next unless sub_service_request.nil? || sub_service_request.organization.name == value[:process_ssr_organization_name]
          livs = Array.new
          arm.line_items_visits.each do |line_items_visit|
            line_item = line_items_visit.line_item
            next unless value[:line_items].include?(line_item)
            livs << line_items_visit
          end
          grouped_livs[value[:name]] = livs unless livs.empty?
        end
      end

      grouped_livs
    end

    def self.set_check(obj)
      count = obj.visits.where('research_billing_qty = 0 and insurance_billing_qty = 0').count
      count != 0
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

    def self.select_row(line_items_visit, tab, portal)
      checked = line_items_visit.visits.all? { |v| v.research_billing_qty >= 1  }
      action = checked ? 'unselect_calendar_row' : 'select_calendar_row'
      icon = checked ? 'glyphicon-remove' : 'glyphicon-ok'

      link_to(
          (content_tag(:span, '', class: "glyphicon #{icon}")),
          "/dashboard/service_calendars/#{action}?service_request_id=#{line_items_visit.line_item.service_request.id}&line_items_visit_id=#{line_items_visit.id}&&portal=#{portal}",
          method: :post,
          remote: true,
          role: 'button',
          class: 'btn btn-primary service_calendar_row',
          id: "check_row_#{line_items_visit.id}_#{tab}",
          data: (line_items_visit.any_visit_quantities_customized? ? { confirm: 'This will reset custom values for this row, do you wish to continue?' } : nil))
    end

    def self.select_column(visit_group, n, portal, sub_service_request)
      arm_id = visit_group.arm_id
      filtered_livs = visit_group.line_items_visits.joins(:line_item).where(line_items: { service_request_id: sub_service_request.service_request_id })
      checked = filtered_livs.all? { |l| l.visits[n.to_i].research_billing_qty >= 1 }
      icon = checked ? 'glyphicon-remove' : 'glyphicon-ok'
      method = if checked
                 'unselect_calendar_column'
               else
                 'select_calendar_column'
               end
      url = "/dashboard/service_calendars/#{method}.js?sub_service_request_id=#{sub_service_request.id}&column_id=#{n + 1}&arm_id=#{arm_id}&portal=#{portal}"

      link_to(content_tag(:span, '', class: "glyphicon #{icon}"), url,
              method: :post, remote: true, role: 'button', class: 'visit_number btn btn-primary',
              id: "check_all_column_#{n+1}",
              data: (visit_group.any_visit_quantities_customized?(sub_service_request.service_request) ? { confirm: 'This will reset custom values for this column, do you wish to continue?' } : nil))
    end
  end
end
