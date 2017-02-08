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

############################################
############################################
## NOTES ABOUT SERVICE CALENDAR VARIABLES ##
############################################
## portal:        Are we accessing the calendar from the dashboard? True or False
##
## admin:         Are we accessing the calendar by clicking Admin Edit from the dashboard? True or False
##
## merged:        Are we accessing the Consolidated Request calendar? True or False
##
## review:        Are we viewing the Step 4 Review calendar? True or False
##
## consolidated:  Are we using the "View Consolidated Request" calendar in dashboard? True or false

class ServiceCalendarsController < ApplicationController
  respond_to :html, :js
  layout false

  before_filter :initialize_service_request,      if: Proc.new{ params[:portal] != 'true' }
  before_filter :authorize_identity,              if: Proc.new { params[:portal] != 'true' }
  before_filter :authorize_dashboard_access,      if: Proc.new { params[:portal] == 'true' }

  def update
    visit         = Visit.find(params[:visit_id])
    @arm          = Arm.find(params[:arm_id])
    @tab          = params[:tab]
    @merged       = params[:merged] == 'true'
    @portal       = params[:portal] == 'true'
    @review       = params[:review] == 'true'
    @admin        = params[:admin] == 'true'
    @consolidated = false
    @pages        = eval(params[:pages])
    @sub_service_request = visit.line_items_visit.sub_service_request if @admin
    @service_request = visit.line_items_visit.sub_service_request.service_request

    visit.line_items_visit.sub_service_request.set_to_draft(@admin)

    if params[:checked] == 'true'
      unit_minimum = visit.line_items_visit.line_item.service.displayed_pricing_map.unit_minimum

      visit.update_attributes(
        quantity: unit_minimum,
        research_billing_qty: unit_minimum
      )
    else
      visit.update_attributes(
        quantity: 0,
        research_billing_qty: 0,
        insurance_billing_qty: 0,
        effort_billing_qty: 0
      )
    end
  end

  def table
    @tab          = params[:tab]
    @review       = params[:review] == 'true'
    @portal       = params[:portal] == 'true'

    if params[:admin]
      @admin = params[:admin] == 'true'
    else
      @admin = @portal && @sub_service_request.present?
    end

    @merged       = false
    @consolidated = false

    setup_calendar_pages

    respond_to do |format|
      format.js
      format.html
    end
  end

  def merged_calendar
    @tab              = params[:tab]
    @review           = params[:review] == 'true'
    @portal           = params[:portal] == 'true'
    @admin            = @portal && @sub_service_request.present?
    @merged           = true
    @consolidated     = false
    @statuses_hidden  = []
    setup_calendar_pages

    respond_to do |format|
      format.js
      format.html
    end
  end

  def view_full_calendar
    @tab                = 'calendar'
    @review             = false
    @portal             = true
    @admin              = false
    @merged             = true
    @consolidated       = true
    @service_request    = @protocol.any_service_requests_to_display?
    @statuses_hidden    = params[:statuses_hidden]
    setup_calendar_pages

    respond_to do |format|
      format.js
    end
  end

  def show_move_visits
    @arm = Arm.find( params[:arm_id] )
    @visit_group = params[:visit_group_id] ? @arm.visit_groups.find(params[:visit_group_id]) : @arm.visit_groups.first
  end

  def move_visit_position
    arm = Arm.find( params[:arm_id] )
    vg  = arm.visit_groups.find( params[:visit_group].to_i )

    vg.insert_at( params[:position].to_i - 1 )
  end

  def toggle_calendar_row
    @line_items_visit  = LineItemsVisit.find(params[:line_items_visit_id])
    @service           = @line_items_visit.line_item.service if params[:check]
    @portal            = params[:portal] == 'true'

    return unless @line_items_visit.sub_service_request.can_be_edited? || @portal

    @line_items_visit.visits.each do |visit|
      if params[:check]
        visit.update_attributes(quantity: @service.displayed_pricing_map.unit_minimum, research_billing_qty: @service.displayed_pricing_map.unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0)
      elsif params[:uncheck]
        visit.update_attributes(quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
      end
    end

    # Update the sub service request only if we are not in dashboard; admin's actions should not affect the status
    unless @portal
      sub_service_request = @line_items_visit.line_item.sub_service_request
      sub_service_request.update_attribute(:status, "draft")
      @service_request.update_attribute(:status, "draft")
    end

    render partial: 'update_service_calendar'
  end

  def toggle_calendar_column
    column_id  = params[:column_id].to_i
    @arm       = Arm.find(params[:arm_id])
    @portal    = params[:portal] == 'true'

    @service_request.service_list(false).each do |_key, value|
      next unless @sub_service_request.nil? || @sub_service_request.organization.name == value[:process_ssr_organization_name] || @sub_service_request.can_be_edited?

      @arm.line_items_visits.each do |liv|
        next if value[:line_items].exclude?(liv.line_item) || (!@portal && (!liv.line_item.sub_service_request.can_be_edited? || liv.line_item.sub_service_request.is_complete?))
        visit = liv.visits[column_id - 1] # columns start with 1 but visits array positions start at 0
        if params[:check]
          visit.update_attributes quantity: liv.line_item.service.displayed_pricing_map.unit_minimum, research_billing_qty: liv.line_item.service.displayed_pricing_map.unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0
        elsif params[:uncheck]
          visit.update_attributes quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0
        end
      end
    end

    # Update the sub service request only if we are not in dashboard; admin's actions should not affect the status
    unless @portal
      @arm.line_items.map(&:sub_service_request).uniq.each do |ssr|
        next if (@sub_service_request && ssr != @sub_service_request)
        next unless ssr.can_be_edited?
        ssr.update_attribute(:status, "draft")
      end
      @service_request.update_attribute(:status, "draft")
    end

    render partial: 'update_service_calendar'
  end

  private

  def authorize_dashboard_access
    if params[:sub_service_request_id]
      authorize_admin
    else
      if params[:service_request_id]
        @service_request = ServiceRequest.find(params[:service_request_id])
      end
      authorize_protocol
    end
  end

  def authorize_protocol
    @protocol = if params[:protocol_id]
                  Protocol.find(params[:protocol_id])
                else
                  Arm.find(params[:arm_id]).protocol
                end
    permission_to_view = @protocol.project_roles.where(identity_id: current_user.id, project_rights: %w(approve request view)).any?

    unless permission_to_view || Protocol.for_admin(current_user.id).include?(@protocol)
      @protocol = nil

      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def authorize_admin
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request     = @sub_service_request.service_request

    unless (current_user.authorized_admin_organizations & @sub_service_request.org_tree).any?
      @sub_service_request = nil
      @service_request = nil
      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def setup_calendar_pages
    @pages  = {}
    page    = params[:page] if params[:page]
    arm_id  = params[:arm_id] if params[:arm_id]
    @arm    = Arm.find(arm_id) if arm_id

    session[:service_calendar_pages]          = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id]  = page if page && arm_id

    @service_request.arms.each do |arm|
      new_page        = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id]  = @service_request.set_visit_page(new_page, arm)
    end
  end
end
