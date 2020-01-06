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

class Dashboard::SubsidiesController < Dashboard::BaseController
  before_action :find_subsidy,              only: [:edit, :update, :destroy, :approve]
  before_action :find_sub_service_request
  before_action :find_protocol
  before_action :protocol_authorizer_edit,  unless: :in_admin?
  before_action :authorize_admin,           if: :in_admin?

  def new
    @subsidy = @sub_service_request.build_pending_subsidy
    @subsidy.percent_subsidy = (@subsidy.default_percentage / 100.0)

    respond_to :js
  end

  def create
    @subsidy = @sub_service_request.build_pending_subsidy(subsidy_params)

    if @admin && @subsidy.percent_subsidy == 0
      @subsidy.save(validate: false)
    else
      @subsidy.save
    end

    flash[:success] = t(:subsidies)[:created]

    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    @subsidy.assign_attributes(subsidy_params)

    if @admin && @subsidy.percent_subsidy != 0
      @subsidy.save(validate: false)
    else
      @subsidy.save
    end

    flash[:success] = t(:subsidies)[:updated]

    respond_to :js
  end

  def destroy
    authorization_error if @subsidy.status == 'Approved' && !@admin
    @subsidy.destroy
    flash[:alert] = t(:subsidies)[:destroyed]

    respond_to :js
  end

  def approve
    authorization_error if !@admin
    @subsidy = @subsidy.grant_approval(current_user)
    @sub_service_request.reload
    flash[:success] = t(:subsidies)[:approve]

    respond_to :js
  end

  private

  def find_subsidy
    @subsidy = Subsidy.find(params[:id])
    @subsidy = @subsidy.becomes("#{@subsidy.status}Subsidy".constantize)
  end

  def find_sub_service_request
    @sub_service_request = @subsidy ? @subsidy.sub_service_request : SubServiceRequest.find(params[:ssrid])
  end

  def find_protocol
    @protocol = @sub_service_request.protocol
  end

  def in_admin?
    @admin = helpers.request_referrer_controller == 'dashboard/sub_service_requests' && helpers.request_referrer_action == 'show'
  end

  def subsidy_params
    if params[:subsidy][:percent_subsidy]
      params[:subsidy][:percent_subsidy] = params[:subsidy][:percent_subsidy].gsub(/[^\d^\.]/, '').to_f / 100
    end

    params.require(:subsidy).permit(
      :sub_service_request_id,
      :overridden,
      :status,
      :percent_subsidy
    )
  end
end
