class ServiceCalendarsController < ApplicationController
  before_filter :initialize_service_request
  before_filter(:except => [:merged_calendar]) {|c| params[:portal] == 'true' ? true : c.send(:authorize_identity)}
  layout false

  def table
    #use session so we know what page to show when tabs are switched
    arm_id = params[:arm_id] if params[:arm_id]
    @arm = Arm.find arm_id if arm_id
    page = params[:page] if params[:page]
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    @tab = params[:tab]
    @portal = params[:portal]
    @study_tracker = params[:study_tracker] == "true"
    @pages = {}
    @protocol = @service_request.protocol
    @service_requests = (@tab == 'calendar') ? @service_request.protocol.service_requests : [@service_request]
    @service_requests.each do |service_request|
      service_request.arms.each do |arm|
        new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
        @pages[arm.id] = @service_request.set_visit_page new_page, arm
      end
    end

    # TODO: This needs to be changed for one time fees page in arms
    @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.is_one_time_fee?} if @sub_service_request
  end

  def update
    @portal = params[:portal]
    @study_tracker = params[:study_tracker] == "true"
    @sub_service_request = SubServiceRequest.find(params[:id]) if (params[:id])
    @subsidy = @sub_service_request.try(:subsidy)
    @user = current_identity
    visit = Visit.find params[:visit] rescue nil
    @line_items_visit = LineItemsVisit.find params[:line_items_visit] rescue nil
    @line_item = LineItem.find params[:line_item] rescue nil
    tab = params[:tab]
    checked = params[:checked]
    qty = params[:qty].to_i
    column = params[:column]
    
    case tab
    when 'template'
      if @line_items_visit
        # TODO: not sure what's going on here (why is @line_items_visit
        # set above, then set again below?  what are we doing here, and
        # why do we not care about checked in this case?)
        @line_items_visit.update_attribute(:subject_count, qty)
      elsif visit.research_billing_qty.to_i <= 0 and checked == 'true'
        # set quantity and research billing qty to 1
        line_item = visit.line_items_visit.line_item
        service = line_item.service
        visit.update_attributes(
          quantity: service.displayed_pricing_map.unit_minimum,
          research_billing_qty: service.displayed_pricing_map.unit_minimum)
      elsif checked == 'false'
        visit.update_attributes(
          quantity: 0,
          research_billing_qty: 0,
          insurance_billing_qty: 0,
          effort_billing_qty: 0)
      end

    when 'quantity'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(:quantity, qty) unless qty < 0

    when 'billing_strategy'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(column, qty) unless qty < 0
      #update the total quantity to reflect the 3 billing qty total
      total = visit.quantity_total
      visit.update_attribute(:quantity, total) unless total < 0
    end

    @visit = visit
    @visit_td = visit.nil? ? "" : ".visits_#{visit.id}"
    @line_items_visit = visit.line_items_visit if @line_items_visit.nil?
    @line_item = @line_items_visit.line_item if @line_item.nil?
    @line_item_total_td = ".total_#{@line_items_visit.id}"
    @line_item_total_study_td = ".total_#{@line_items_visit.id}_per_study"
    @arm_id = '.arm_' + @line_items_visit.arm.id.to_s
  end

  def rename_visit
    name = params[:name]
    position = params[:visit_position].to_i
    arm = Arm.find params[:arm_id]

    arm.visit_groups[position].update_attribute(:name, name)
  end

  def set_day
    day = params[:day]
    position = params[:position].to_i
    arm = Arm.find params[:arm_id]

    if !arm.update_visit_group_day(day, position)
      respond_to do |format|
        format.js { render :status => 418, :json => clean_messages(arm.errors.messages) }
      end
    end
  end

  def set_window
    window = params[:window]
    position = params[:position].to_i
    arm = Arm.find params[:arm_id]

    if !arm.update_visit_group_window(window, position)
      respond_to do |format|
        format.js { render :status => 418, :json => clean_messages(arm.errors.messages) }
      end
    end
  end

  def merged_calendar
    arm_id = params[:arm_id] if params[:arm_id]
    @arm = Arm.find arm_id if arm_id
    page = params[:page] if params[:page]
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    @tab = params[:tab]
    @portal = params[:portal]
    @study_tracker = params[:study_tracker] == "true"
    @pages = {}
    @protocol = @arm.protocol rescue @service_request.protocol
    @protocol.arms.each do |arm|
      new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id] = @service_request.set_visit_page new_page, arm
    end
  end
end
