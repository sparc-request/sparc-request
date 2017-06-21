# Copyright © 2011-2016 MUSC Foundation for Research Development
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

module ServiceCalendarHelper

  def currency_converter cents
    number_to_currency(Service.cents_to_dollars(cents))
  end

  def display_service_rate line_item
    full_rate = line_item.service.displayed_pricing_map.full_rate

    currency_converter(full_rate)
  end

  def display_liv_notes(liv, portal)
  has_notes = liv.notes.count > 0
  raw(content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-list-alt note-icon #{has_notes ? "blue-note" : "black-note"}", aria: {hidden: "true"}))+raw(content_tag(:span, liv.notes.count, class: "#{has_notes ? "badge blue-badge" : "badge"}", id: "lineitemsvisit_#{liv.id}_notes")), type: 'button', class: 'btn btn-link form-control actions-button notes', data: {notable_id: liv.id, notable_type: "LineItemsVisit", in_dashboard: portal}))
  end

  def display_li_notes(li, portal)
    has_notes = li.notes.count > 0
    raw(content_tag(:button, raw(content_tag(:span, '', class: "glyphicon glyphicon-list-alt note-icon #{has_notes ? "blue-note" : "black-note"}", aria: {hidden: "true"}))+raw(content_tag(:span, li.notes.count, class: "#{has_notes ? "badge blue-badge" : "badge"}", id: "lineitem_#{li.id}_notes")), type: 'button', class: 'btn btn-link form-control actions-button notes', data: {notable_id: li.id, notable_type: "LineItem", in_dashboard: portal}))
  end

  def notable_type_is_related_to_li_or_liv(notable_type)
    notable_type == "LineItemsVisit" || notable_type == "LineItem"
  end

  def display_freeze_header_button_pppv(tab, portal, arm, service_request, sub_service_request, merged, statuses_hidden)
    if portal && tab != "calendar"
      add_scrollable_class = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, merged: merged, statuses_hidden: statuses_hidden).map{|x| x.last}.flatten.count > 9
    else
      line_item_visits = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, merged: merged, statuses_hidden: statuses_hidden).map{|x| x.last}.flatten
      line_item_visit_count = line_item_visits.count
      ssr_count = line_item_visits.map(&:sub_service_request).uniq.count
      add_scrollable_class = portal ? (line_item_visit_count + ssr_count) > 10 : (line_item_visit_count + ssr_count) > 8
    end
    add_scrollable_class
  end

  def display_freeze_header_button_otf(service_request)
    @line_items = []
    service_request.service_list(true).each do |_, value|
      value[:line_items].group_by(&:sub_service_request_id).each do |sub_service_request_id, line_items|
        @line_items << line_items
      end
    end
    line_item_count = @line_items.flatten.count
    
    ssr_count = @line_items.flatten.map(&:sub_service_request).uniq.count
    (line_item_count + ssr_count) > 10
  end

  def display_unit_type(liv)
    unit_type = liv.line_item.service.displayed_pricing_map.unit_type
    unit_type = unit_type.gsub("/", "/ ")
    unit_type
  end

  def display_service_name_and_code(notable_type, notable_id)
    case notable_type
    when "LineItem"
      LineItem.find(notable_id.to_i).service.name + (LineItem.find(notable_id.to_i).service.cpt_code.present? ? " (" + LineItem.find(notable_id.to_i).service.cpt_code + ")" : "")
    when "LineItemsVisit"
      LineItemsVisit.find(notable_id.to_i).line_item.service.name + (LineItemsVisit.find(notable_id.to_i).line_item.service.cpt_code.present? ? " (" + LineItemsVisit.find(notable_id.to_i).line_item.service.cpt_code + ")" : "")
    end
  end

  def display_your_cost line_item
    currency_converter(line_item.applicable_rate)
  end

  def update_per_subject_subtotals line_items_visit
    line_items_visit.per_subject_subtotals
  end

  def display_org_name(org_name, ssr, locked)
    header  = content_tag(:span, org_name + (ssr.ssr_id ? " (#{ssr.ssr_id})" : ""))
    header += content_tag(:span, '', class: 'glyphicon glyphicon-lock locked') if locked
    header
  end

  #############################################
  # Visit Based Services
  #############################################
  # Displays line item totals
  def display_visit_based_direct_cost(line_items_visit)
    currency_converter(line_items_visit.direct_costs_for_visit_based_service_single_subject)
  end

  def display_visit_based_direct_cost_per_study(line_items_visit)
    currency_converter(line_items_visit.direct_costs_for_visit_based_service_single_subject * line_items_visit.subject_count)
  end

  # Displays max totals per patient
  def display_max_total_direct_cost_per_patient arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = arm.maximum_direct_costs_per_patient line_items_visits
    currency_converter sum
  end

  def display_max_total_cost_per_patient arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = arm.maximum_total_per_patient line_items_visits
    currency_converter sum
  end

  def display_total_cost_per_arm arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = arm.total_costs_for_visit_based_service(line_items_visits)
    currency_converter sum
  end

  # Displays grand totals per study
  def display_total_direct_cost_per_study_pppvs service_request
    sum = service_request.total_direct_costs_per_patient
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_pppvs service_request
    sum = service_request.total_indirect_costs_per_patient
    currency_converter sum
  end

  def display_total_cost_per_study_pppvs service_request
    sum = service_request.total_costs_per_patient
    currency_converter(sum)
  end

  # Displays max totals per patient per visit
  def update_visit_data_cents visit
    visit.cost unless visit.nil?
  end

  #############################################
  # One Time Fee Services
  #############################################
  # Display line item totals
  def display_one_time_fee_direct_cost line_item
    currency_converter line_item.direct_costs_for_one_time_fee
  end

  # Display grand totals per study
  def display_total_direct_cost_per_study_otfs service_request, line_items
    sum = service_request.total_direct_costs_one_time line_items
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_otfs service_request, line_items
    sum = service_request.total_indirect_costs_one_time line_items
    currency_converter sum
  end

  def display_total_cost_per_study_otfs service_request, line_items
    sum = service_request.total_costs_one_time line_items
    currency_converter sum
  end

  #############################################
  # Grand Totals
  #############################################
  def display_ssr_grand_total sub_service_request
    sum = sub_service_request.grand_total
    currency_converter sum
  end

  def display_grand_total_direct_costs service_request, line_items
    sum = service_request.direct_cost_total line_items
    currency_converter sum
  end

  def display_grand_total_indirect_costs service_request, line_items
    sum = service_request.indirect_cost_total line_items
    currency_converter sum
  end

  def display_grand_total service_request, line_items
    sum = service_request.grand_total line_items
    currency_converter sum
  end

  def display_study_grand_total_direct_costs protocol, service_request
    sum = protocol.direct_cost_total service_request
    currency_converter sum
  end

  def display_study_grand_total_indirect_costs protocol, service_request
    sum = protocol.indirect_cost_total service_request
    currency_converter sum
  end

  def display_study_grand_total protocol, service_request
    sum = protocol.grand_total service_request
    currency_converter sum
  end

  #############################################
  # Other
  #############################################
  def qty_cost_label qty, cost
    return nil if qty == 0
    cost = cost || "$0.00"
    "#{qty} - #{cost}"
  end
end
