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

class Dashboard::VisitGroupsController < Dashboard::BaseController
  respond_to :json, :html
  before_action :find_visit_group, only: [:update, :destroy]

  def new
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @current_page = params[:current_page] # the current page of the study schedule
    @protocol = Protocol.find(params[:protocol_id])
    @visit_group = VisitGroup.new
    @schedule_tab = params[:schedule_tab]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  def create
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @arm =  Arm.find(params[:visit_group][:arm_id])
    @visit_group = VisitGroup.new(params[:visit_group])
    if @visit_group.valid?
      if @arm.add_visit(@visit_group.position, @visit_group.day, @visit_group.window_before, @visit_group.window_after, @visit_group.name, 'true')
        @service_request.relevant_service_providers_and_super_users.each do |identity|
          create_visit_change_toast(identity, @sub_service_request) unless identity == @user
        end
        flash[:success] = t(:dashboard)[:visit_groups][:created]
      else
        @errors = @arm.errors
      end
    else
      @errors = @visit_group.errors
    end
  end

  def navigate
    # Used in study schedule management for navigating to a visit group, given an index of them by arm.
    @protocol = Protocol.find(params[:protocol_id])
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @intended_action = params[:intended_action]
    if params[:visit_group_id]
      @visit_group = VisitGroup.find(params[:visit_group_id])
      @arm = @visit_group.arm
    else
      @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
      @visit_group = @arm.visit_groups.first
    end
  end

  def update
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @arm = @visit_group.arm
    if @visit_group.update_attributes(params[:visit_group])
      flash[:success] = t(:dashboard)[:visit_groups][:updated]
    else
      @errors = @visit_group.errors
    end
  end

  def destroy
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @arm = @visit_group.arm
    if @arm.remove_visit(@visit_group.position)
      @arm.decrement!(:minimum_visit_count)
      @service_request.relevant_service_providers_and_super_users.each do |identity|
        create_visit_change_toast(identity, @sub_service_request) unless identity == @user
      end
      flash.now[:alert] = t(:dashboard)[:visit_groups][:destroyed]
    else
      @errors = @arm.errors
    end
  end

  private

  def find_visit_group
    @visit_group = VisitGroup.find(params[:id])
  end

  def create_visit_change_toast identity, sub_service_request
    ToastMessage.create(
      to: identity.id,
      from: current_identity.id,
      sending_class: 'SubServiceRequest',
      sending_class_id: sub_service_request.id,
      message: 'The visit count on this service request has been changed'
    )
  end
end
