class ServiceCalendarsController < ApplicationController
  layout false
  def table
    #use session so we know what page to show when tabs are switched
    session[:service_calendar_page] = params[:page] if params[:page]

    @service_request = ServiceRequest.find session[:service_request_id]
    @tab = params[:tab]
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
  end

  def update
    visit = Visit.find params[:visit] rescue nil
    
    @line_item = LineItem.find params[:line_item] rescue nil
    tab = params[:tab]
    checked = params[:checked]
    qty = params[:qty].to_i
    column = params[:column]

    if tab == 'template' and @line_item
      @line_item.update_attribute(:subject_count, qty)
    elsif tab == 'template' and visit.research_billing_qty.to_i <= 0 and checked == 'true'
      # set quantity and research billing qty to 1
      visit.update_attribute(:quantity, visit.line_item.service.displayed_pricing_map.unit_minimum)
      visit.update_attribute(:research_billing_qty, visit.line_item.service.displayed_pricing_map.unit_minimum)
    elsif tab == 'template' and checked == 'false'
      visit.update_attribute(:quantity, 0)
      visit.update_attribute(:research_billing_qty, 0)
      visit.update_attribute(:insurance_billing_qty, 0)
      visit.update_attribute(:effort_billing_qty, 0)
    elsif tab == 'quantity'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(:quantity, qty) unless qty < 0
    elsif tab == 'billing_strategy'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(column, qty) unless qty < 0
      #update the total quantity to reflect the 3 billing qty total
      total = visit.research_billing_qty.to_i + visit.insurance_billing_qty.to_i + visit.effort_billing_qty.to_i
      visit.update_attribute(:quantity, total) unless total < 0
    end

    @visit = visit
    @visit_td = visit.nil? ? "" : ".visits_#{visit.id}"
    @line_item = visit.line_item if @line_item.nil?
    @line_item_total_td = ".total_#{@line_item.id}"
    @displayed_visits = @line_item.visits.paginate(page: params[:page], per_page: 5)
    @service_request = ServiceRequest.find session[:service_request_id]
  end
end
