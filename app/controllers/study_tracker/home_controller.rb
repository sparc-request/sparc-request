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

class StudyTracker::HomeController < StudyTracker::BaseController
  def index
    @study_tracker = true
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer

    ##Passing in ctrc organization id, in order to only get ctrc ssrs back (method defaults to all ssrs)
    @org = Organization.tagged_with("ctrc").first
    @service_requests = @user.admin_service_requests_by_status(@org.id)

    ##Remove ssrs that are not flagged for study tracker/work fulfillment
    @service_requests.each_value do |status|
    	status.delete_if {|ssr| ssr.in_work_fulfillment == nil}
    end


    #redirect_to root_path if @user.admin_organizations.empty?
  end

  def billing_report_setup
    @admin_portal = true
    @render_billing_report = true
    @study_tracker = true
    # get cwf organizations
    @cwf_organizations = Organization.in_cwf
    @protocols = SubServiceRequest.where(:in_work_fulfillment => true).map{|x| x.service_request.protocol}.uniq
  end

  def billing_report
    @start = params[:study_tracker_billing_report_start_date]
    @end = params[:study_tracker_billing_report_end_date]
    @protocol_ids = params[:study_tracker_billing_report_protocol_ids] || ["All"]
    @protocol_ids.delete("All")

    if @protocol_ids.blank? or @protocol_ids == ["All"]
      @protocol_ids = SubServiceRequest.where(:in_work_fulfillment => true).map{|x| x.service_request.protocol.id}.uniq
    end

    @organization_ids = params[:organizations]

    @appointments = Appointment.joins(:visit_group => :arm)
                               .where("organization_id IN (#{@organization_ids.join(', ')}) AND completed_at BETWEEN '#{@start}' AND '#{@end}' AND arms.protocol_id IN (#{@protocol_ids.join(', ')})")
                               .order("arms.protocol_id", :organization_id, :calendar_id, :completed_at)
  end
end
