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

class Dashboard::LineItemsVisitsController < Dashboard::BaseController
  respond_to :json, :js, :html

  def destroy
    @line_items_visit = LineItemsVisit.find(params[:id])
    @sub_service_request = @line_items_visit.line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @selected_arm = @service_request.arms.first
    line_item = @line_items_visit.line_item
    @line_items = @sub_service_request.line_items

    ActiveRecord::Base.transaction do
      @line_items_visit.remove_procedures
      if @line_items_visit.destroy
        line_item.destroy unless line_item.line_items_visits.count > 0
        # Have to reload the service request to get the correct direct cost total for the subsidy
        @service_request = @sub_service_request.service_request
        @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition(&:one_time_fee)
        render 'dashboard/sub_service_requests/add_line_item'
      end
    end
  end
end
