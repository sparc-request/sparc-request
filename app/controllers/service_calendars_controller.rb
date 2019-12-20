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

############################################
############################################
## NOTES ABOUT SERVICE CALENDAR VARIABLES ##
############################################
## portal:        Are we accessing the calendar from the dashboard? True or False
##                Assigned by in_dashboard?
##
## admin:         Are we accessing the calendar by clicking Admin Edit from the dashboard? True or False
##                Assigned by in_dashboard?
##
## merged:        Are we accessing the Consolidated Request calendar? True or False
##
## review:        Are we viewing the Step 4 Review calendar? True or False
##
## consolidated:  Are we using the "View Consolidated Request" calendar in dashboard? True or false

class ServiceCalendarsController < ApplicationController
  before_action :initialize_service_request,  unless: :in_dashboard?
  before_action :authorize_identity,          unless: :in_dashboard?
  before_action :authorize_dashboard_access,  if: :in_dashboard?

  before_action :preload_service_request

  after_action :set_service_calendar_cookie, only: [:table, :merged_calendar]


  def table
    @merged               = false
    @consolidated         = false
    @tab                  = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def merged_calendar
    @merged               = true
    @consolidated         = false
    @tab                  = 'calendar'
    @show_unchecked       = params[:show_unchecked] == 'true'
    setup_calendar_pages

    respond_to :js
  end

  def view_full_calendar
    @merged                 = true
    @consolidated           = true
    @tab                    = 'calendar'
    @show_draft             = params[:show_draft] == 'true'
    @show_unchecked         = params[:show_unchecked] == 'true'
    @service_request        = @protocol.any_service_requests_to_display?
    setup_calendar_pages

    respond_to :js
  end

  def toggle_calendar_row
    @tab                = 'template'
    @page               = params[:page]
    @line_items_visit   = LineItemsVisit.eager_load(sub_service_request: { organization: { parent: { parent: :parent } } }, line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]]]).find(params[:line_items_visit_id])
    @arm                = @line_items_visit.arm
    @line_items_visits  = @arm.line_items_visits.eager_load(line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol])
    @visit_groups       = @arm.visit_groups.paginate(page: @page.to_i, per_page: VisitGroup.per_page).eager_load(visits: { line_items_visit: { line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol] } })
    @visits             = @line_items_visit.ordered_visits.eager_load(service: :pricing_maps)

    Visit.transaction do
      if params[:check]
        unit_minimum = @line_items_visit.line_item.service.displayed_pricing_map.unit_minimum
        @visits.each{ |v| v.update_attributes(quantity: unit_minimum, research_billing_qty: unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0) }
      elsif params[:uncheck]
        @visits.each{ |v| v.update_attributes(quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0) }
      end
    end

    # Update the sub service request only if we are not in dashboard; admin's actions should not affect the status
    unless @in_admin
      @line_items_visit.sub_service_request.update_attribute(:status, "draft")
      @service_request.update_attribute(:status, "draft")
    end

    respond_to :js
  end

  def toggle_calendar_column
    @tab                = 'template'
    @page               = params[:page]
    @visit_group        = VisitGroup.find(params[:visit_group_id])
    @arm                = @visit_group.arm
    @line_items_visits  = @arm.line_items_visits.eager_load(line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol])
    @visit_groups       = @arm.visit_groups.paginate(page: @page.to_i, per_page: VisitGroup.per_page).eager_load(visits: { line_items_visit: { line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol] } })

    editable_ssrs =
      if @sub_service_request
        SubServiceRequest.where(id: @sub_service_request)
      else
        SubServiceRequest.where(id: @arm.sub_service_requests.eager_load(organization: { parent: { parent: :parent } }).select{ |ssr| ssr.can_be_edited? })
      end

    @visits = @visit_group.visits.joins(:sub_service_request).where(sub_service_requests: { id: editable_ssrs }).eager_load(service: :pricing_maps, line_items_visit: { line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol] })

    Visit.transaction do
      if params[:check]
        @visits.each do |v|
          unit_minimum = v.service.displayed_pricing_map.unit_minimum
          v.update_attributes(quantity: unit_minimum, research_billing_qty: unit_minimum, insurance_billing_qty: 0, effort_billing_qty: 0)
        end
      elsif params[:uncheck]
        @visits.each{ |v| v.update_attributes(quantity: 0, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0) }
      end
    end

    # Update the sub service request only if we are not in dashboard; admin's actions should not affect the status
    unless @in_admin
      editable_ssrs.where.not(status: 'draft').update_all(status: 'draft')
      @service_request.update_attribute(:status, "draft")
    end

    respond_to :js
  end

  private

  def preload_service_request
    ActiveRecord::Associations::Preloader.new.preload(@service_request, { sub_service_requests: { organization: [:editable_statuses, parent: [:editable_statuses, parent: [:editable_statuses, :parent]]] } })
  end

  def set_service_calendar_cookie
    if in_dashboard?
      cookies["calendar-tab-ssr-#{@sub_service_request.id}"] = @tab
    else
      cookies["calendar-tab-sr-#{@service_request.id}"] = @tab
    end
  end
end
