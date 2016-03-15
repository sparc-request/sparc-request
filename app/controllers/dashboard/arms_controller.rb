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

class Dashboard::ArmsController < Dashboard::BaseController

  respond_to :json, :html
  before_action :find_arm, only: [:update, :destroy]

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
    name = params[:arm][:name] || "ARM #{@protocol.arms.count + 1}"
    visit_count = params[:arm][:visit_count] ? params[:arm][:visit_count].to_i : 1
    subject_count = params[:arm][:subject_count] ? params[:arm][:subject_count].to_i : 1

    if @selected_arm = @protocol.create_arm(name: name, visit_count: visit_count, subject_count: subject_count)
      @selected_arm.default_visit_days
      @selected_arm.reload
      # If any sub service requests under this arm's protocol are in CWF we need to build patient calendars
      if @protocol.sub_service_requests.any? { |ssr| ssr.in_work_fulfillment? }
        @selected_arm.populate_subjects
      end
      flash[:success] = "Arm Created!"
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
      flash[:success] = "Arm Updated!"
    else
      @errors = @arm.errors
    end
  end

  def destroy
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request

    @arm.destroy
    @service_request.reload

    if @service_request.arms.empty?
      @service_request.per_patient_per_visit_line_items.each(&:destroy)
    else
      @selected_arm = @service_request.arms.first
    end
    flash[:alert] = "Arm Destroyed!"
  end

  private

  def find_arm
    @arm = Arm.find(params[:id])
  end

end
