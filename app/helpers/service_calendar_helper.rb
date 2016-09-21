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

  def select_row(line_items_visit, tab, portal, locked)
    checked = line_items_visit.visits.map{|v| v.research_billing_qty >= 1}.all?
    check_param = checked ? 'uncheck' : 'check'
    icon = checked ? 'ui-icon-close' : 'ui-icon-check'

    if !locked
      link_to(
          (content_tag(:span, '', :class => "ui-button-icon-primary ui-icon #{icon}") + content_tag(:span, 'Check All', :class => 'ui-button-text')),
          "/service_requests/#{line_items_visit.line_item.service_request.id}/toggle_calendar_row/#{line_items_visit.id}?#{check_param}=true&portal=#{portal}",
          :method  => :post,
          :remote  => true,
          :role    => 'button',
          :class   => "ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only service_calendar_row",
          :id      => "check_row_#{line_items_visit.id}_#{tab}",
          data:    ( line_items_visit.any_visit_quantities_customized? ? { confirm: "This will reset custom values for this row, do you wish to continue?" } : nil))
    else
      content_tag(:a,
        (content_tag(:span, '', class: 'ui-button-icon-primary ui-icon ui-icon-locked') + content_tag(:span, 'Check All', :class => 'ui-button-text')),
        class: 'ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only',
        role: 'button'
      )
    end
  end

  def currency_converter cents
    number_to_currency(Service.cents_to_dollars(cents))
  end

  def display_service_rate line_item
    full_rate = line_item.service.displayed_pricing_map.full_rate

    full_rate < line_item.applicable_rate ? "" : currency_converter(full_rate)
  end

  def display_your_cost line_item
    currency_converter(line_item.applicable_rate)
  end

  def update_per_subject_subtotals line_items_visit
    line_items_visit.per_subject_subtotals
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

  def display_max_total_indirect_cost_per_patient arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = arm.maximum_indirect_costs_per_patient line_items_visits
    currency_converter sum
  end

  def display_max_total_cost_per_patient arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = arm.maximum_total_per_patient line_items_visits
    currency_converter sum
  end

  def display_total_cost_per_arm arm, line_items_visits=nil
    line_items_visits ||= arm.line_items_visits
    sum = 0
    sum = arm.total_costs_for_visit_based_service(line_items_visits)
    currency_converter sum
  end

  # Displays grand totals per study
  def display_total_direct_cost_per_study_pppvs service_request
    sum = 0
    sum = service_request.total_direct_costs_per_patient
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_pppvs service_request
    sum = 0
    sum = service_request.total_indirect_costs_per_patient
    currency_converter sum
  end

  def display_total_cost_per_study_pppvs service_request
    sum = 0
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
    sum = 0
    sum = service_request.total_direct_costs_one_time line_items
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_otfs service_request, line_items
    sum = 0
    sum = service_request.total_indirect_costs_one_time line_items
    currency_converter sum
  end

  def display_total_cost_per_study_otfs service_request, line_items
    sum = 0
    sum = service_request.total_costs_one_time line_items
    currency_converter sum
  end

  # Display protocol total
  def display_protocol_total_otfs protocol, current_request, portal
    sum = 0
    protocol.service_requests.each do |service_request|
      next unless service_request.has_one_time_fee_services?
      if ['first_draft'].include?(service_request.status)
        next if portal
        next if service_request != current_request
      end
      sum += service_request.total_costs_one_time
    end
    currency_converter sum
  end

  #############################################
  # Grand Totals
  #############################################
  def display_grand_total_direct_costs service_request, line_items
    sum = 0
    sum = service_request.direct_cost_total line_items
    currency_converter sum
  end

  def display_grand_total_indirect_costs service_request, line_items
    sum = 0
    sum = service_request.indirect_cost_total line_items
    currency_converter sum
  end

  def display_grand_total service_request, line_items
    sum = 0
    sum = service_request.grand_total line_items
    currency_converter sum
  end

  def display_study_grand_total_direct_costs protocol, service_request
    sum = 0
    sum = protocol.direct_cost_total service_request
    currency_converter sum
  end

  def display_study_grand_total_indirect_costs protocol, service_request
    sum = 0
    sum = protocol.indirect_cost_total service_request
    currency_converter sum
  end

  def display_study_grand_total protocol, service_request
    sum = 0
    sum = protocol.grand_total service_request
    currency_converter sum
  end

  #############################################
  # Other
  #############################################
  def visits_to_move arm
    unless arm.visit_groups.empty?
      vgs = arm.visit_groups
      last_position = vgs.count

      arr = []
      vgs.each do |vg|
        visit_name = vg.name
        arr << ["#{visit_name}", vg.position]
      end
    else
      arr = [["No Visits", nil]]
    end

    options_for_select(arr)
  end

  def move_to_position arm
    unless arm.visit_groups.empty?
      vgs = arm.visit_groups
      arr = []
      vgs.each do |vg|
        visit_name = vg.name
        arr << ["Insert at #{vg.position} - #{visit_name}", vg.position]
      end
    else
      arr = [["No Visits", nil]]
    end

    options_for_select(arr)
  end

  def display_line_items_status(line_item)
    AVAILABLE_STATUSES[line_item.sub_service_request.status]
  end

  def display_per_patient_calendar?(service_request, sub_service_request, merged)
    (sub_service_request.nil? ? service_request.has_per_patient_per_visit_services? : sub_service_request.has_per_patient_per_visit_services?) or merged
  end
end
