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

class Dashboard::SubsidiesController < Dashboard::BaseController
  respond_to :json, :js, :html
  before_action :find_subsidy, only: [:edit, :update, :destroy]

  def new
    @subsidy = Subsidy.new(sub_service_request_id: params[:sub_service_request_id])
    @header_text = "New Subsidy Pending Approval"
  end

  def create
    if @subsidy = Subsidy.create(params[:subsidy])
      @sub_service_request = @subsidy.sub_service_request
      @subsidy.update_attribute(:pi_contribution, @sub_service_request.direct_cost_total)
      @subsidy.update_attributes(:stored_percent_subsidy => @subsidy.percent_subsidy)
      flash[:success] = "Subsidy Created!"
    else
      @errors = @subsidy.errors
    end
  end

  def edit
    @header_text = "Edit Subsidy Pending Approval"
  end

  def update
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.update_attributes(params[:subsidy])
      flash[:success] = "Subsidy Updated!"
    else
      @errors = @subsidy.errors
      @subsidy.reload
    end
  end

  def destroy
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.destroy
      flash[:alert] = "Subsidy Destroyed!"
    end
  end

  def approve
    @subsidy = PendingSubsidy.find params[:id]
    @subsidy = @subsidy.grant_approval current_user
    @sub_service_request = @subsidy.sub_service_request
    flash[:success] = "Subsidy Approved!"
  end

  private

  def find_subsidy
    @subsidy = Subsidy.find(params[:id])
  end
end
