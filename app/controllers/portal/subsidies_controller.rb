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

class Portal::SubsidiesController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @subsidy = Subsidy.find(params[:id])
    total = @subsidy.sub_service_request.direct_cost_total
    percent_subsidy = 0.0
    pi_contribution = 0.0
    # Fix pi_contribution to be in cents
    data = params[:subsidy]
    if params[:percent_subsidy]
      subsidy = (params[:percent_subsidy].to_f / 100.0) * total
      data[:pi_contribution] = (total - subsidy) / 100
    elsif params[:pi_contribution]
      pi_contribution =  (params[:pi_contribution].to_f * 100.0)
      percent_subsidy = total - pi_contribution
      percent_subsidy = ((percent_subsidy / total) * 100).round(2)
    end

    data[:pi_contribution] = data[:pi_contribution].to_f * 100.0
    data[:overridden] = true

    percent_subsidy = params[:percent_subsidy] ? params[:percent_subsidy] : percent_subsidy
    pi_contribution = params[:percent_subsidy] ? data[:pi_contribution] : pi_contribution

    if @subsidy.update_attributes(data)
      @sub_service_request = @subsidy.sub_service_request
      @subsidy.update_attributes(:stored_percent_subsidy => percent_subsidy)
      @subsidy.update_attributes(:pi_contribution => pi_contribution)
      render 'portal/sub_service_requests/add_subsidy'
    else
      respond_to do |format|
        format.json { render :status => 500, :json => clean_errors(@subsidy.errors) } 
      end
    end
  end

  def create
    if @subsidy = Subsidy.create(params[:subsidy])
      @sub_service_request = @subsidy.sub_service_request
      @subsidy.update_attribute(:pi_contribution, @sub_service_request.direct_cost_total)
      @subsidy.update_attributes(:stored_percent_subsidy => @subsidy.percent_subsidy)
      render 'portal/sub_service_requests/add_subsidy'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@subsidy.errors) } 
      end
    end
  end

  def destroy
    @subsidy = Subsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.delete
      @subsidy = nil
      @service_request = @sub_service_request.service_request
      render 'portal/sub_service_requests/add_subsidy'
    end
  end

end
