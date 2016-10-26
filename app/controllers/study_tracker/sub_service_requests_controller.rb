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

class StudyTracker::SubServiceRequestsController < StudyTracker::BaseController
  respond_to :js, :html
  before_filter :check_work_fulfillment_status

  def show
    # TODO it might be nice to move these into a separate method so that
    # other methods (notably, update) can load up the necesary instance
    # methods without having to call #show, in case we add unintended
    # side-effects to #show

    session[:sub_service_request_id] = @sub_service_request.id
    session[:service_request_id] = @sub_service_request.service_request_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]

    @service_request = @sub_service_request.service_request
    @protocol = Protocol.find(@service_request.protocol_id)
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.one_time_fee}
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}

    @line_items = LineItem.where(:sub_service_request_id => @sub_service_request.id)

    @selected_arm = @service_request.arms.first

    @study_tracker = true

    # "Preload" the intial view of the payments and study level charges tabs with a blank form row
    @sub_service_request.payments.build if @sub_service_request.payments.blank?
    build_fulfillments

    # get cwf organizations
    @cwf_organizations = Organization.in_cwf

    # min start date and max end date
    cwf_audit = @sub_service_request.audits.where(:audited_changes => YAML.dump({'in_work_fulfillment' => [false, true]})).first
    @min_start_date = cwf_audit.nil? ? "N/A" : cwf_audit.created_at.utc
    @max_end_date = Time.now.utc
  end

  def service_calendar
    @service_request = @sub_service_request.service_request
  end

  def update
    if @sub_service_request.update_attributes(params[:sub_service_request])
      respond_to do |format|
        format.js { render :js => "$('.routing_message').removeClass('uncheck').addClass('check')" }
        format.html { redirect_to study_tracker_sub_service_request_path(@sub_service_request) }
      end
    else
      respond_to do |format|
        format.js { render :js => "$('.routing_message').removeClass('check').addClass('uncheck')" }
        format.html do
          # handle errors
          show
          render :show
        end
      end
    end
  end

  private
  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end

  def build_fulfillments
    @sub_service_request.one_time_fee_line_items.each do |line_item|
      line_item.fulfillments.build if line_item.fulfillments.blank?
    end
  end
end
