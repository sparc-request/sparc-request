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

class VisitsController < ApplicationController
  before_action :initialize_service_request, unless: :in_dashboard?
  before_action :authorize_identity,         unless: :in_dashboard?
  before_action :authorize_admin,            if: :in_dashboard?

  def edit
    @visit = Visit.find(params[:id])

    respond_to :js
  end

  def update
    @tab                = params[:tab]
    @page               = params[:page]
    @visit              = Visit.eager_load(sub_service_request: { organization: { parent: { parent: :parent } } }, service: :pricing_maps).find(params[:id])
    @arm                = @visit.arm
    @line_items_visits  = @arm.line_items_visits.eager_load(line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol])
    @line_items_visit   = @line_items_visits.find(@visit.line_items_visit_id)
    @visit_groups       = @arm.visit_groups.paginate(page: @page.to_i, per_page: VisitGroup.per_page).eager_load(visits: { line_items_visit: { line_item: [:admin_rates, service: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]], service_request: :protocol] } })
    @visit_group        = @arm.visit_groups.find(@visit.visit_group_id)
    @locked             = !@visit.sub_service_request.can_be_edited? && !@in_admin

    if @visit.update_attributes(visit_params)
      @visit.sub_service_request.set_to_draft unless @in_admin
    else
      @errors = @visit.errors
    end

    respond_to :js
  end

  def destroy
    @visit = Visit.find(params[:id])
    line_item = @visit.line_items_visit.line_item
    @sub_service_request = line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    position = @visit.position
    arm = @visit.line_items_visit.arm

    if arm.remove_visit(position)
      # Change the pi_contribution on the subsidy in accordance with the new direct cost total
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      render 'dashboard/service_requests/add_per_patient_per_visit_visit'
    end

    respond_to :js
  end

  private

  def visit_params
    params.require(:visit).permit(
      :research_billing_qty,
      :insurance_billing_qty,
      :effort_billing_qty
    )
  end
end
