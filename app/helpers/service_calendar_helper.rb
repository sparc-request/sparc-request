# Copyright © 2011-2019 MUSC Foundation for Research Development
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

  def calendar_service(liv_or_li)
    line_item = liv_or_li.is_a?(LineItem) ? liv_or_li : liv_or_li.line_item
    text      = line_item.service.display_service_name
    text     += inactive_tag unless line_item.service.is_available
    raw(text)
  end

  def display_service_rate line_item
    full_rate = line_item.service.displayed_pricing_map.full_rate

    currency_converter(full_rate)
  end

  def display_unit_type(liv)
    liv.line_item.service.displayed_pricing_map.unit_type.gsub("/", "/ ")
  end

  def display_your_cost line_item
    currency_converter(line_item.applicable_rate)
  end

  def display_org_name(org_name, ssr, locked, complete)
    header = content_tag(:strong, "(#{ssr.ssr_id})", class: 'mr-2') + org_name

    if complete
      header += icon('fas', 'check fa-lg ml-2')
    elsif locked
      header += icon('fas', 'lock fa-lg ml-2')
    end

    content_tag :span, header
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
  def display_total_direct_cost_per_study_otfs(service_request)
    currency_converter(service_request.total_direct_costs_one_time)
  end

  def display_total_indirect_cost_per_study_otfs service_request, line_items
    sum = service_request.total_indirect_costs_one_time line_items
    currency_converter sum
  end

  def display_total_cost_per_study_otfs(service_request)
    currency_converter(service_request.total_costs_one_time)
  end

  #############################################
  # Grand Totals
  #############################################
  def display_ssr_grand_total sub_service_request
    sum = sub_service_request.direct_cost_total
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

  def display_study_grand_total_direct_costs(protocol, service_request)
    currency_converter(protocol.direct_cost_total(service_request))
  end

  def display_study_grand_total_indirect_costs protocol, service_request
    sum = protocol.indirect_cost_total service_request
    currency_converter sum
  end

  def display_study_grand_total(protocol, service_request)
    currency_converter(protocol.grand_total(service_request))
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
