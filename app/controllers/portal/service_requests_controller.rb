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

class Portal::ServiceRequestsController < Portal::BaseController
  respond_to :json, :js, :html

  def show
    arm_id = params[:arm_id] if params[:arm_id]
    page = params[:page] if params[:page]
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id

    @service_request = ServiceRequest.find(params[:id])
    @ssr_id = params[:ssr_id] if params[:ssr_id]
    @sub_service_request = @service_request.sub_service_requests.find_by_ssr_id(@ssr_id) if @ssr_id
    @service_list = @service_request.service_list
    @line_items = @sub_service_request.line_items
    @protocol = @service_request.protocol
    @tab = 'calendar'
    @portal = true
    @thead_class = 'ui-widget-header'
    @review = true
    @selected_arm = Arm.find arm_id if arm_id
    @pages = {}
    @service_request.arms.each do |arm|
      new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id] = @service_request.set_visit_page new_page, arm
    end

    respond_to do |format|
      format.js
    end
  end

  def add_per_patient_per_visit_visit
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @service_request = ServiceRequest.find(params[:service_request_id]) # TODO: is this different from params[:id] ?
    @selected_arm = Arm.find(params[:arm_id])
    @study_tracker = params[:study_tracker] == "true"
    
    if @selected_arm.add_visit(params[:visit_position], params[:visit_day], params[:visit_window], params[:visit_name])
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      @selected_arm.update_attributes(:minimum_visit_count => @selected_arm.minimum_visit_count + 1)
      @service_request.relevant_service_providers_and_super_users.each do |identity|
        create_visit_change_toast(identity, @sub_service_request) unless identity == @user
      end
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@selected_arm.errors) }
      end
    end
  end

  def remove_per_patient_per_visit_visit
    @service_request = ServiceRequest.find(params[:id])
    @selected_arm = Arm.find(params[:arm_id])
    @study_tracker = params[:study_tracker] == "true"

    if @selected_arm.remove_visit(params[:visit_position])
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      @subsidy = @sub_service_request.subsidy
      percent = @subsidy.try(:percent_subsidy).try(:*, 100)
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      @selected_arm.update_attributes(:minimum_visit_count => @selected_arm.minimum_visit_count - 1)
      @service_request.relevant_service_providers_and_super_users.each do |identity|
        create_visit_change_toast(identity, @sub_service_request) unless identity == @user
      end
      render 'portal/service_requests/add_per_patient_per_visit_visit'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@selected_arm.errors) }
      end
    end
  end

  def update_from_fulfillment
    @service_request = ServiceRequest.find(params[:id])
    if @service_request.update_attributes(params[:service_request])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@service_request.errors) } 
      end
    end
  end

  ##### NOT ACTIONS #####
  def visit_count_total
    max_count = 0
    @service_request.sub_service_requests.each do |sub_service_request|
      sub_service_request.services.each do |service|
        if service.visits
          length = service.visits.length
          max_count = length if max_count < service.visits.length
        end
      end
    end
    max_count
  end

  def create_visit_change_toast identity, sub_service_request
    ToastMessage.create(
      :to => identity.id,
      :from => current_identity.id,
      :sending_class => 'SubServiceRequest',
      :sending_class_id => sub_service_request.id,
      :message => "The visit count on this service request has been changed"
    )
  end

end
