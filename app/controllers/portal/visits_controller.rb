# Copyright © 2011 MUSC Foundation for Research Development
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

class Portal::VisitsController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @visit = Visit.find(params[:id])
    line_item = @visit.line_items_visit.line_item
    @sub_service_request = line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    if @visit.update_attributes(params[:visit])
      # Change the pi_contribution on the subsidy in accordance with the new direct cost total
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      render 'portal/sub_service_requests/add_subsidy' # Re-render the subsidy information as total cost may be updated
      # render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@visit.errors) } 
      end
    end
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

    if arm.remove_visit(position) then
      # Change the pi_contribution on the subsidy in accordance with the new direct cost total
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      render 'portal/service_requests/add_per_patient_per_visit_visit'
    end
  end
end
