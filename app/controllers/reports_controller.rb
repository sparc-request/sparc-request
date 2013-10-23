class ReportsController < ApplicationController
  def research_project_summary
    @sub_service_request = SubServiceRequest.find params[:id]
    @service_request = @sub_service_request.service_request 
    @protocol = @service_request.protocol

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
        
        subject.calendar.appointments.each do |appointment|
          @audit_trail += appointment.procedures.includes(:service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
          @audit_trail += appointment.procedures.includes(:line_item => :service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
          @audit_trail += appointment.appointment_completions.where("organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
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
    @arm = Arm.find params[:arm]
    @sub_service_request = SubServiceRequest.find params[:id]
    @service_request = @sub_service_request.service_request 
    @protocol = @service_request.protocol
  end
end
