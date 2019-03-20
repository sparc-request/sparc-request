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

class Dashboard::VisitGroupsController < Dashboard::BaseController
  respond_to :json, :html

  before_action :find_visit_group,          only: [:update, :destroy]
  before_action :find_service_request
  before_action :find_sub_service_request
  before_action :find_protocol,             only: [:new, :navigate]
  before_action :authorize_admin_visit_group

  def new
    @current_page = params[:current_page] # the current page of the study schedule
    @schedule_tab = params[:schedule_tab]
    @visit_group  = VisitGroup.new
    @arm          = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  def create
    @arm        = Arm.find(create_params[:arm_id])
    visit_group = @arm.visit_groups.create(create_params)

    if visit_group.valid?
      flash[:success] = t(:dashboard)[:visit_groups][:created]
    else
      @errors = visit_group.errors
    end
  end

  def navigate
    # Used in study schedule management for navigating to a visit group, given an index of them by arm.
    @intended_action = params[:intended_action]

    if params[:visit_group_id]
      @visit_group  = VisitGroup.find(params[:visit_group_id])
      @arm          = @visit_group.arm
    else
      @arm          = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
      @visit_group  = @arm.visit_groups.first
    end
  end

  def update
    @arm = @visit_group.arm
    
    if @visit_group.update_attributes(update_params)
      flash[:success] = t(:dashboard)[:visit_groups][:updated]
    else
      @errors = @visit_group.errors
    end
  end

  def destroy
    @arm = @visit_group.arm

    if @visit_group.destroy
      flash.now[:alert] = t(:dashboard)[:visit_groups][:destroyed]
    else
      @errors = @arm.errors
    end
  end

  private

  def create_params
    params.require(:visit_group).permit(:name,
      :position,
      :arm_id,
      :day,
      :window_before,
      :window_after)
  end

  def update_params
    temp = params.require(:visit_group).permit(:name,
      :position,
      :arm_id,
      :day,
      :window_before,
      :window_after)
    
    if @visit_group.position < temp[:position].to_i
      temp[:position] = temp[:position].to_i - 1
    end
    
    temp
  end

  def find_visit_group
    @visit_group = VisitGroup.find(params[:id])
  end

  def find_service_request
    @service_request = ServiceRequest.find(params[:service_request_id])
  end

  def find_sub_service_request
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
  end

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

  def authorize_admin_visit_group
    unless (@user.authorized_admin_organizations & @sub_service_request.org_tree).any?
      @protocol            = nil
      @service_request     = nil
      @sub_service_request = nil
      @visit_group         = nil

      # This is an intruder
      flash[:alert] = t(:authorization_error)[:dashboard][:visit_groups]
      redirect_to dashboard_root_path
    end
  end
end
