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

class ReportsController < ApplicationController
  layout "reporting"
  protect_from_forgery
  helper_method :current_user

  before_filter :authenticate_identity!
  before_filter :require_super_user, :only => [:index, :setup, :generate]
  before_filter :set_user
  before_filter :set_show_navbar

  def set_highlighted_link
    @highlighted_link ||= 'sparc_report'
  end

  def current_user
    current_identity
  end

  def set_user
    @user = current_identity
    session['uid'] = @user.nil? ? nil : @user.id
  end

  def set_show_navbar
    @show_navbar = true
  end

  def require_super_user
    redirect_to root_path unless current_identity.is_super_user?
  end

  def index
  end

  def setup
    report = params[:report]
    @report = report.constantize.new
    @date_ranges = @report.options.select{|k,v| v[:field_type] == :date_range} # select out the date ranges
    render :layout => false
  end

  def generate
    report_params = params[:report]
    report = report_params[:type]
    @report = report.constantize.new report_params

    # generate excel
    tempfile = @report.to_excel
    send_file tempfile.path, :filename => 'report.xlsx', :disposition => 'inline', :type =>  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

    # generate csv
    #tempfile = @report.to_csv
    #send_file tempfile.path, :type => 'text/csv', :disposition => 'inline', :filename => 'report.csv'
  end

  def research_project_summary
    @sub_service_request = SubServiceRequest.find params[:id]
    @service_request = @sub_service_request.service_request
    @protocol = @service_request.protocol
    @start_date = params[:start_date].blank? ? nil : Date.parse(params[:start_date])
    @end_date = params[:end_date].blank? ? nil : Date.parse(params[:end_date])

    xlsx_string = render_to_string xlsx: "research_project_summary", filename: "research_project_summary.xlsx"

    xlsx = StringIO.new(xlsx_string)
    xlsx.class.class_eval { attr_accessor :original_filename, :content_type }
    xlsx.original_filename = "research_project_summary.xlsx"
    xlsx.content_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

    report = @sub_service_request.reports.new
    report.xlsx = xlsx
    report.report_type = "research_project_summary"

    report.save

    redirect_to study_tracker_sub_service_request_path(@sub_service_request)
  end

  def cwf_audit
    included_cores = params[:organizations] || []

    @ssr = SubServiceRequest.find params[:id]

    if params[:min_start_date].to_time.strftime('%Y-%m-%d') == params[:cwf_audit_start_date]
      start_date = params[:min_start_date].to_time.strftime("%Y-%m-%d %H:%M:%S")
    else
      start_date = params[:cwf_audit_start_date] + " 00:00:00"
    end

    end_date = params[:cwf_audit_end_date] + " 23:59:59"

    @audit_trail = @ssr.audit_trail start_date, end_date
    @audit_trail += @ssr.past_statuses.map{|x| x.audit_trail start_date, end_date}
    @audit_trail += @ssr.line_items.includes(:service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
    @audit_trail += @ssr.notes.map{|x| x.audit_trail start_date, end_date}
    @audit_trail += @ssr.payments.map{|x| x.audit_trail start_date, end_date}
    @audit_trail += @ssr.cover_letters.map{|x| x.audit_trail start_date, end_date}
    if @ssr.subsidy
      @audit_trail += @ssr.subsidy.audit_trail start_date, end_date
    end
    @audit_trail += @ssr.reports.map{|x| x.audit_trail start_date, end_date}

    @ssr.service_request.protocol.arms.each do |arm|
      @audit_trail += arm.audit_trail start_date, end_date
      @audit_trail += arm.line_items_visits.includes(:line_item => :service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
      @audit_trail += arm.subjects.map{|x| x.audit_trail start_date, end_date}

      arm.subjects.each do |subject|
        if subject.calendar
          @audit_trail += subject.calendar.audit_trail start_date, end_date
          @audit_trail += subject.calendar.appointments.map{|x| x.audit_trail start_date, end_date}
        end

        subject.calendar.appointments.where("organization_id IN (?)", included_cores).each do |appointment|
          @audit_trail += appointment.procedures.includes(:service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
          @audit_trail += appointment.procedures.includes(:line_item => :service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
          @audit_trail += appointment.notes.map{|x| x.audit_trail start_date, end_date}
        end
      end
      @audit_trail += arm.visits.includes(:line_items_visit => {:line_item => :service}).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
      @audit_trail += arm.visit_groups.map{|x| x.audit_trail start_date, end_date}
    end

    @audit_trail.flatten!
    @audit_trail.compact!
    @audit_trail.sort_by!(&:created_at)
  end

  def cwf_subject
    @subject = Subject.find params[:subject]
    @subject.calendar.populate_on_request_edit
    @subject.calendar.build_subject_data
    @arm = Arm.find params[:arm]
    @sub_service_request = SubServiceRequest.find params[:id]
    @service_request = @sub_service_request.service_request
    @protocol = @service_request.protocol
  end
end
