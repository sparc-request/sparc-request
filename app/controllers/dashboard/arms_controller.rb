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

class Dashboard::ArmsController < Dashboard::BaseController
  respond_to :json, :html
  before_action :find_arm, only: [:update]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @arm = Arm.new(protocol_id: params[:protocol_id])
    @schedule_tab = params[:schedule_tab]
  end

  def create
    @protocol = Protocol.find(params[:arm][:protocol_id])
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    name = params[:arm][:name]
    visit_count = params[:arm][:visit_count].try(:to_i)
    subject_count = params[:arm][:subject_count].try(:to_i)
    protocol_id = params[:arm][:protocol_id].to_i

    arm_builder = Dashboard::ArmBuilder.new(name: name,
      visit_count: visit_count,
      subject_count: subject_count,
      protocol_id: protocol_id)
    @selected_arm = arm_builder.arm

    if @selected_arm.valid?
      flash[:success] = t(:dashboard)[:arms][:created]
    else
      @errors = @selected_arm.errors
    end
  end

  def navigate
    # Used in study schedule management for navigating to a arm.
    @protocol = Protocol.find(params[:protocol_id])
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @intended_action = params[:intended_action]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  def update
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    if @arm.update_attributes(params[:arm])
      flash[:success] = t(:dashboard)[:arms][:updated]
    else
      @errors = @arm.errors
    end
  end

  def destroy
    destroyer = Dashboard::ArmDestroyer.new(id: params[:id],
      sub_service_request_id: params[:sub_service_request_id])
    destroyer.destroy

    @sub_service_request = destroyer.sub_service_request
    @service_request = destroyer.service_request
    @selected_arm = destroyer.selected_arm

    flash[:alert] = t(:dashboard)[:arms][:destroyed]
  end

  private

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
