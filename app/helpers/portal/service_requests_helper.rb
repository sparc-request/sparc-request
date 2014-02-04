module Portal::ServiceRequestsHelper
  # def currency_converter cents
  # def display_one_time_fee_direct_cost line_item
  # def display_visit_based_direct_cost(line_item)
  # def display_your_cost line_item
  # def generate_review_visit_navigation service_request, page, tab
  # def generate_visit_header_row service_request, page
  # def calculate_total(service, project)
  #   begin
  #     units_we_want = 0
  #     service.visits.each {|visit| visit['quantity']}.each{ |quantity| units_we_want += quantity['quantity']}
  #     units_per_package = service.try(:pricing_map).try(:[], 'unit_factor') || 1
  #     packages_we_have_to_get = (units_we_want / units_per_package).ceil
  #     total_cost = packages_we_have_to_get * service.pricing_map.send(:[], (project.project_rate + "_rate"))
  #     "%.2f" % (total_cost / units_we_want)
  #   rescue
  #     "N/A"
  #   end
  # end

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

  def default_display workflow_state
    workflow_state == 'submitted' ? '' : 'display:none;'
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
        last_position.times do |visit|
          visit_name = vg.visits[visit].visit_group.name || "Visit #{visit}"
          arr << ["Insert before #{visit + 1} - #{visit_name}", visit + 1]
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
    vg = arm.line_items_visits.first
    visit_count = vg.visits.count
    arr = []
    visit_count.times do |visit|
      visit_name = vg.visits[visit].visit_group.name || "Visit #{visit}"
      arr << ["Delete Visit #{visit + 1} - #{visit_name}", visit + 1]
    end

    options_for_select(arr, vg.visits.count)
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
    remaining_visits.times { |i| visit_quantities += create_quantity_content_tag('', service_id, visits_length < 5 ? i + visits_length : i) }

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
end
