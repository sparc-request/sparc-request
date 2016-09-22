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

class Dashboard::SubsidiesController < Dashboard::BaseController
  respond_to :json, :js, :html

  def new
    @subsidy = PendingSubsidy.new(sub_service_request_id: params[:sub_service_request_id])
    @header_text = t(:dashboard)[:subsidies][:new]
    @admin = params[:admin] == 'true'
    @subsidy.percent_subsidy = @subsidy.default_percentage
  end

  def create
    format_percent_subsidy_param
    @subsidy = PendingSubsidy.new(params[:pending_subsidy].except(:pi_contribution))
    admin_param = params[:admin] == 'true'

    if admin_param && (params[:pending_subsidy][:percent_subsidy] != 0)
      @subsidy.save(validate: false)
      perform_subsidy_creation(admin_param)
    else
      if @subsidy.valid?
        @subsidy.save 
        perform_subsidy_creation
      else
        @errors = @subsidy.errors
      end
    end
  end

  def edit
    @subsidy = PendingSubsidy.find(params[:id])
    @header_text = t(:dashboard)[:subsidies][:edit]
    @admin = params[:admin] == 'true'
  end

  def update
    @subsidy = PendingSubsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    admin_param = params[:admin] == 'true'
    format_percent_subsidy_param

    if admin_param && (params[:pending_subsidy][:percent_subsidy] != 0)
      @subsidy.assign_attributes(params[:pending_subsidy].except(:pi_contribution))
      @subsidy.save(validate: false)
      perform_subsidy_update(admin_param)
    else
      if @subsidy.update_attributes(params[:pending_subsidy].except(:pi_contribution))
        perform_subsidy_update
      else
        @errors = @subsidy.errors
        @subsidy.reload
      end
    end
  end

  def destroy
    @subsidy = Subsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.destroy
      @admin = true
      flash[:alert] = t(:dashboard)[:subsidies][:destroyed]
    end
  end

  def approve
    subsidy = PendingSubsidy.find(params[:id])
    subsidy = subsidy.grant_approval(current_user)
    @sub_service_request = subsidy.sub_service_request.reload
    @admin = true
    flash[:success] = t(:dashboard)[:subsidies][:approved]
  end

  private

  def format_percent_subsidy_param
    if !params[:pending_subsidy].nil? && params[:pending_subsidy][:percent_subsidy].present?
      params[:pending_subsidy][:percent_subsidy] = ((params[:pending_subsidy][:percent_subsidy].gsub(/[^\d^\.]/, '').to_f) / 100)
    end
  end

  def perform_subsidy_creation(admin_param=false)
    @sub_service_request = @subsidy.sub_service_request
    @admin = admin_param
    flash[:success] = t(:dashboard)[:subsidies][:created]
    unless @admin
      redirect_to dashboard_sub_service_request_path(@sub_service_request, format: :js)
    end
  end

  def perform_subsidy_update(admin_param=false)
    @admin = admin_param
    flash[:success] = t(:dashboard)[:subsidies][:updated]
    unless @admin
      redirect_to dashboard_sub_service_request_path(@sub_service_request, format: :js)
    end
  end
end
