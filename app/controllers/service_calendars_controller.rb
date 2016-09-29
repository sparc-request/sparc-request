
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

class ServiceCalendarsController < ApplicationController
  before_filter :initialize_service_request
  before_filter(except: [:merged_calendar, :rename_visit]) do |c|
    params[:portal] == 'true' ? true : c.send(:authorize_identity)
  end
  layout false

  def table
    #use session so we know what page to show when tabs are switched
    @tab = params[:tab]
    @portal = params[:portal] 
    @study_tracker = params[:study_tracker] == "true"
    @protocol = @service_request.protocol
    setup_calendar_pages
    # TODO: This needs to be changed for one time fees page in arms
    if @sub_service_request
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition { |x| x.one_time_fee }
    end
  end

  def update
    @portal              = params[:portal]
    @study_tracker       = params[:study_tracker] == "true"
    @sub_service_request = SubServiceRequest.find(params[:id]) if params[:id]
    @user                = current_identity
    visit                = Visit.find params[:visit] rescue nil
    @line_items_visit    = LineItemsVisit.find params[:line_items_visit] rescue nil
    @line_item           = LineItem.find params[:line_item] rescue nil
    tab                  = params[:tab]
    checked              = params[:checked]
    qty                  = params[:undefined].nil? ? params[:qty].to_i : params[:undefined][:qty].to_i
    column               = params[:column]

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

        visit.attributes = {
          quantity: service.displayed_pricing_map.unit_minimum,
          research_billing_qty: service.displayed_pricing_map.unit_minimum
        }
        visit.save

      elsif checked == 'false'
        visit.update_attributes(
          quantity: 0,
          research_billing_qty: 0,
          insurance_billing_qty: 0,
          effort_billing_qty: 0
        )
      end

    when 'quantity'
      if qty < 0
        @errors = "Quantity must be greater than zero"
      else
        visit.update_attribute(:quantity, qty)
      end

    when 'billing_strategy'
      if @line_items_visit
        # TODO: not sure what's going on here (why is @line_items_visit
        # set above, then set again below?  what are we doing here, and
        # why do we not care about checked in this case?)
        @line_items_visit.update_attribute(:subject_count, qty)
      end

      if visit
        if qty < 0
          @errors = "Quantity must be greater than zero"
        else
          #update the total quantity to reflect the 3 billing qty total
          total = visit.quantity_total

          visit.attributes = {
            column => qty,
            quantity: total
          }
          visit.save
        end
      end
    end

    @visit = visit
    @visit_td = visit.nil? ? "" : ".visits_#{visit.id}"
    @line_items_visit = visit.line_items_visit if @line_items_visit.nil?
    @line_item = @line_items_visit.line_item if @line_item.nil?
    @line_item_total_td = ".total_#{@line_items_visit.id}"
    @line_item_total_study_td = ".total_#{@line_items_visit.id}_per_study"
    @arm_id = '.arm_' + @line_items_visit.arm.id.to_s

    @line_items_visits =
      if @sub_service_request
        @line_items_visit.arm.line_items_visits.joins(:line_item)
          .where(line_items: { sub_service_request_id: @sub_service_request.id } )
      elsif @service_request
        @line_items_visit.arm.line_items_visits.joins(:line_item)
          .where(line_items: { service_request_id: @service_request.id } )
      else
        @line_items_visit.arm.line_items_visits
      end
    @line_item.sub_service_request.update_attribute(:status, "draft") if @line_item.sub_service_request
  end

  def rename_visit
    name = params[:name]
    position = params[:visit_position].to_i
    arm = Arm.find params[:arm_id]
    arm.visit_groups[position].update_attributes(name: name)
  end

  def set_day
    day = params[:day]
    position = params[:position].to_i
    arm = Arm.find params[:arm_id]
    portal = params[:portal]

    if !arm.update_visit_group_day(day, position, portal)
      respond_to do |format|
        format.js { render status: 418, json: clean_messages(arm.errors.messages) }
        arm.valid?
      end
    end
  end

  def set_window_before
    window_before = params[:window_before]
    position = params[:position].to_i
    arm = Arm.find params[:arm_id]

    if !arm.update_visit_group_window_before(window_before, position)
      respond_to do |format|
        format.js { render status: 418, json: clean_messages(arm.errors.messages) }
      end
    end
  end

  def set_window_after
    window_after = params[:window_after]
    position = params[:position].to_i
    arm = Arm.find params[:arm_id]

    if !arm.update_visit_group_window_after(window_after, position)
      respond_to do |format|
        format.js { render status: 418, json: clean_messages(arm.errors.messages) }
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
    @merged = true
  end

  def update_otf_qty_and_units_per_qty
    line_item = LineItem.find params[:line_item_id]

    val = params[:val]
    if params[:type] == 'qty'
      line_item.quantity = val
      if line_item.valid?
        line_item.save
      else
        line_item.reload
        respond_to do |format|
          format.js { render status: 500, json: clean_errors(line_item.errors) }
        end
      end
    elsif params[:type] == 'units_per_qty'
      line_item.update_attributes(units_per_quantity: val)
    end
    line_item.sub_service_request.update_attribute(:status, "draft") if line_item.sub_service_request
  end

  def show_move_visits
    @arm = Arm.find params[:arm_id]
    @tab = params[:tab]
    @portal = params[:portal]
  end

  def move_visit_position
    @arm = Arm.find params[:arm_id]
    @tab = params[:tab]

    @portal = params[:portal]
    @protocol = @service_request.protocol

    visit_to_move = params[:visit_to_move].to_i
    move_to_position = params[:move_to_position].to_i

    if @portal
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject { |x| x.one_time_fee }
    end
    setup_calendar_pages

    @arm.visit_groups.reload
    vg = @arm.visit_groups.find_by_position visit_to_move
    vg.reload

    vg.insert_at(move_to_position)

    @arm.reload
    @arm.visit_groups.reload
  end

  def toggle_calendar_row
    @line_items_visit = LineItemsVisit.find(params[:line_items_visit_id])
    @sub_service_request = @line_items_visit.line_item.sub_service_request
    @service = @line_items_visit.line_item.service if params[:check]

    @line_items_visit.visits.each do |visit|
      if params[:uncheck]
        visit.update_attributes(quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
      elsif params[:check]
        visit.update_attributes(quantity: @service.displayed_pricing_map.unit_minimum, research_billing_qty: @service.displayed_pricing_map.unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0)
      end
    end

    @sub_service_request.update_attribute(:status, "draft") if @sub_service_request
    render partial: 'update_service_calendar'
  end

  def toggle_calendar_column
    column_id = params[:column_id].to_i
    @arm = Arm.find(params[:arm_id])

    @service_request.service_list(false).each do |_key, value|
      next unless @sub_service_request.nil? || @sub_service_request.organization.name == value[:process_ssr_organization_name]

      @arm.line_items_visits.each do |liv|
        next unless value[:line_items].include?(liv.line_item) && liv.line_item.sub_service_request.can_be_edited? && !liv.line_item.sub_service_request.is_complete?
        visit = liv.visits[column_id - 1] # columns start with 1 but visits array positions start at 0
        if params[:check]
          visit.update_attributes quantity: liv.line_item.service.displayed_pricing_map.unit_minimum, research_billing_qty: liv.line_item.service.displayed_pricing_map.unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0
        elsif params[:uncheck]
          visit.update_attributes quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0
        end
          
      end
    end

    @sub_service_request.update_attribute(:status, "draft") if @sub_service_request

    render partial: 'update_service_calendar'
  end

  

  private

  def setup_calendar_pages
    @pages = {}
    page = params[:page] if params[:page]
    arm_id = params[:arm_id] if params[:arm_id]
    @arm = Arm.find(arm_id) if arm_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    @service_request.arms.each do |arm|
      new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
    end
  end
end
