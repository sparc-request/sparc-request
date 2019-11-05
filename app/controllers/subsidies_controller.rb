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

class SubsidiesController < ApplicationController
  before_action :find_subsidy,              only: [:edit, :update, :destroy, :approve]
  before_action :find_sub_service_request
  before_action :initialize_service_request
  before_action :authorize_identity
  before_action :in_admin?

  def new
    @subsidy                  = @sub_service_request.build_pending_subsidy
    @subsidy.percent_subsidy  = (@subsidy.default_percentage / 100.0)

    respond_to :js
  end

  def create
    @subsidy = @sub_service_request.build_pending_subsidy(subsidy_params)
    
    if @subsidy.save
      flash[:success] = t(:subsidies)[:created]
    else
      @errors = @subsidy.errors
    end

    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    @subsidy.update_attributes(subsidy_params)
    flash[:success] = t(:subsidies)[:updated]

    respond_to :js
  end

  def destroy
    @subsidy.destroy
    flash[:alert] = t(:subsidies)[:destroyed]

    respond_to :js
  end

  private

  def find_subsidy
    @subsidy = action_name == 'destroy' ? Subsidy.find(params[:id]) : PendingSubsidy.find(params[:id])
  end

  def find_sub_service_request
    @sub_service_request = @subsidy ? @subsidy.sub_service_request : SubServiceRequest.find(params[:ssrid])
  end

  def in_admin?
    @admin = false
  end

  def subsidy_params
    if params[:subsidy][:percent_subsidy]
      params[:subsidy][:percent_subsidy] = params[:subsidy][:percent_subsidy].gsub(/[^\d^\.]/, '').to_f / 100
    end

    params.require(:subsidy).permit(
      :percent_subsidy
    )
  end
end
