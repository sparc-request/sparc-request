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

module Dashboard::ServiceRequestsHelper

  def modify_request_button_url(service_request)
    catalog_service_request_path(service_request, { edit_original: true })
  end

  def protocol_panel_header_line service_request
    if service_request.status == "submitted"
      "Service Request: #{service_request.id} - Submitted - #{format_date(service_request.submitted_at)}"
    else
      "Service Request: #{service_request.id} - #{AVAILABLE_STATUSES[service_request.status]} - #{format_date(service_request.updated_at)}"
    end
  end

  def service_selected(service_name, selected_service_name)
    service_name == selected_service_name
  end

  def timeframe_selected(timeframe, timeframe_selected)
    timeframe == timeframe_selected
  end

  def populate_fulfillment_time fulfillment
    case fulfillment.try(:[], 'timeframe')
    when 'Hours'
      fulfillment['time'].to_f / 60
    when 'Days'
      fulfillment['time'].to_f / 1440
    else
      fulfillment['time']
    end
  end

  def default_display workflow_state, desired_status
    workflow_state == desired_status ? '' : 'display:none;'
  end

  def calculate_status_quantity service_requests, status
    service_requests.select{|ssr| ssr.status == status}.length || 0
  end

  def display_requester requester
    "#{requester['first_name']} #{requester['last_name']}"
  end

  def display_pi roles
    role = roles.find{ |role| role['role'] == 'pi' || role['role'] == 'primary-pi' }
    "#{role['first_name']} #{role['last_name']}"
  end

  def max_visit_count sub_service_request
    line_items_visits = sub_service_request.line_items.map { |li| li.line_items_visits }
    line_items_visits.flatten!
    visit_counts = line_items_visits.map { |vg| vg.visits.count }

    return visit_counts.max
  end

  def pre_select_billing_type billing_type, option
    billing_type == option
  end

  def owners_for_select(ssr)
    if ssr
      unless ssr.candidate_owners.empty?
        candidate_owners = ssr.candidate_owners.map {|x| [x.full_name, x.id]}
        return options_for_select(candidate_owners, ssr.owner_id)
      else
        return options_for_select([])
      end
    else
      return options_for_select([])
    end
  end

  def arms_for_select service_request, selected_arm
    arr = service_request.arms.map { |arm| [ arm.name, arm.id ] }
    options_for_select(arr, selected_arm.id)
  end

  # This method is ugly
  def visits_for_select arm
    unless arm.line_items_visits.empty?
      vg = arm.line_items_visits.first
      unless vg.visits.empty?
        # If there are position attributes set, use positon
        if vg.visits.last.position
          unless vg.visits.last.position.blank?
            last_position = vg.visits.last.position
          else
            last_position = vg.visits.count
          end
        # If position is for some reason nil (IT SHOULD NOT BE) use count
        else
          last_position = vg.visits.count
        end
        arr = [["Add Visit #{last_position + 1}", nil]]
        visits = Visit.where(:line_items_visit_id => vg.id).includes(:visit_group)
        visits = visits.sort_by{|index| index.try(:position)}
        last_position.times do |visit|
          visit_name = visits[visit].try(:visit_group).try(:name) || "Visit #{visit}"
          arr << ["Insert at #{visit + 1} - #{visit_name}", visit + 1]
        end
      else
        arr = [["Add Visit 1", nil]]
      end
    else
      arr = []
    end

    options_for_select(arr)
  end

  def visits_for_delete arm
    unless arm.line_items_visits.empty?
      vg = arm.line_items_visits.first
        if vg.visits.size > 1
          visit_count = vg.visits.last.position
          arr = []
          visits = Visit.where(:line_items_visit_id => vg.id).includes(:visit_group)
          visits = visits.sort_by{|index| index.try(:position)}
          visit_count.times do |visit|
            visit_name = visits[visit].try(:visit_group).try(:name) || "Visit #{visit}"
            arr << ["Delete Visit #{visit + 1} - #{visit_name}", visit + 1]
          end
        else
          arr = [["Visit 1", nil]]
        end
    else
      arr = []
      visit_count = 0
    end

    options_for_select(arr, visit_count)
  end

  def visit_size_for_arm arm
    vg = arm.line_items_visits.first
    if vg
      return vg.visits.size
    end
  end


  def display_visit_quantity(li)
    visit_quantities = ""
    service_id = li.service.id
    visits_length = li.visits.length
    remaining_visits = 5
    if li.visits && visits_length > 0
      li.visits.each_with_index do |visit, i|
        package_cost = determine_package_cost(@project, li.service)
        cost_arr = sub_totals(li, li.service, package_cost)
        cost_in_dollars = if cost_arr[i] == 'N/A'
                            "N/A"
                          else
                            "$#{two_decimal_places(cost_arr[i].floor * 0.01) rescue "N/A"}"
                          end

        @visits_array[i][:values] << { :service_id => service_id, :cost => cost_arr[i] }
        visit_quantities += create_quantity_content_tag(cost_in_dollars, service_id, i + 1) if i < 5
      end
      remaining_visits -= visits_length
    end
    remaining_visits.times { |i| visit_quantities += create_quantity_content_tag('', service_id, visits_length < 5 ? i + visits_length +1 : i + 1) }

    visit_quantities.html_safe
  end

  def create_quantity_content_tag(display_text, service_id, num)
    content_tag(:td, display_text, :class => 'visit_quantity', :id => "quantity_#{service_id}_column_#{num}")
  end

  def display_cost_per_service(quantity, package_cost)
    if package_cost == "N/A"
      "N/A"
    else
      quantity = quantity.to_f
      cost = package_cost.to_f * 0.01
      "$#{two_decimal_places(quantity * cost)}"
    end
  end

  def determine_package_cost(project, service)
    service.determine_package_cost(project.id)
  end

  def determine_per_unit_cost(project, li)
    package_cost = determine_package_cost(project, li.service)
    package_cost == "N/A" ? package_cost : PriceGrabber::Business.per_unit_cost(li.service.pricing_map, package_cost, li.quantity)
  end

  def sub_totals(li, service, package_cost)
    ##li.instance_values is the "line_item" that the per_subject_subtotals requires
    PriceGrabber::Business.per_subject_subtotals(li.instance_values, package_cost, service.pricing_map)
  end

  def display_total(project, one_time_fees, per_patient_per_visit, type)
    total = "#{total_totals(project, one_time_fees, per_patient_per_visit)[type].to_s.to_f * 0.01}"
    "$#{two_decimal_places(total)}"
  end

  def total_totals(project, one_time_fees, per_patient_per_visit)
    begin
      line_items_and_rate_maps = (one_time_fees + per_patient_per_visit).flatten.map{|li| {"line_item" => li.instance_values, "rate" => li.service.determine_package_cost(project.id), "pricing_map" => li.service.pricing_map}}
      PriceGrabber::Business.total_totals(project.indirect_cost_rate, line_items_and_rate_maps)
    rescue
      "N/A"
    end
  end

  def display_service_total(li)
    amount = 0
    package_cost = determine_package_cost(@project, li.service)
    cost_arr = sub_totals(li, li.service, package_cost)
    cost_arr.each { |value| amount += value if value != 'N/A'}
    if [0, 0.00, 0.0].include?(amount)
      "N/A"
    else
      "$#{two_decimal_places(amount.floor * 0.01)}"
    end
  end

  # This method is broken (Core no longer has attributes like this)
  # def services_are_available(ls, service, li, core)
  #   core.try(:attributes).try(:[], 'is_available') == true && !(ls.is_available == false && service['name'] != li.service.name)
  # end

  def core_is_available(service)
    core = service.build_core

    begin
      return (@program_attrs.is_available == true && core.attributes['is_available'] == true) || false
    rescue
      return (@program_attrs.is_available == true && core.is_available == true) rescue return false
    end
  end

  def display_one_time_fee_direct_cost line_item
    currency_converter line_item.direct_costs_for_one_time_fee
  end

  def only_has_first_draft_requests(protocol)
    protocol.service_requests.any? && protocol.service_requests.map(&:status).all? { |status| status == 'first_draft'}
  end

  def has_draft_request(protocol)
    if protocol.service_requests.any?
      (protocol.service_requests.last.status == 'draft') && (protocol.service_requests.last.line_items.count == 0)
    end
  end
end
