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
    # changes to the following models
    # protocol
    #   affiliations 
    #   study_types
    #   research_types_info
    #   human_subjects_info
    #   vertebrate_animals_info
    #   ip_patents_info
    #   project_roles
    #   impact_areas
    #   arms
    # arms
    #   line_items_visits
    #   subjects
    #   visit_groups
    # sub_service_request
    #   owner
    #   line_items
    #   documents
    #   notes
    #   approvals
    #   payments
    #   cover_letters
    #   subsidy
    # calendars   
    # appointments
    # cover_letters
    # 
    nursing    = Organization.tagged_with("nursing").first
    laboratory = Organization.tagged_with("laboratory").first
    imaging    = Organization.tagged_with("imaging").first
    nutrition  = Organization.tagged_with("nutrition").first

    nursing_included = params[:nursing_included] || false
    laboratory_included = params[:laboratory_included] || false
    imaging_included = params[:imaging_included] || false
    nutrition_included = params[:nutrition_included] || false

    included_cores = []
    included_cores << nursing.id if nursing_included
    included_cores << laboratory.id if laboratory_included
    included_cores << imaging.id if imaging_included
    included_cores << nutrition.id if nutrition_included
    
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
    @audit_trail += @ssr.subsidy.audit_trail start_date, end_date
    @audit_trail += @ssr.reports.map{|x| x.audit_trail start_date, end_date}
  
    @ssr.service_request.protocol.arms.each do |arm|
      @audit_trail += arm.audit_trail start_date, end_date
      @audit_trail += arm.line_items_visits.includes(:line_item => :service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
      @audit_trail += arm.subjects.map{|x| x.audit_trail start_date, end_date}

      arm.subjects.each do |subject|
        @audit_trail += subject.calendar.audit_trail start_date, end_date
        @audit_trail += subject.calendar.appointments.map{|x| x.audit_trail start_date, end_date}
        
        subject.calendar.appointments.each do |appointment|
          @audit_trail += appointment.procedures.includes(:service).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
          @audit_trail += appointment.notes.map{|x| x.audit_trail start_date, end_date}
        end
      end
      @audit_trail += arm.visits.includes(:line_items_visit => {:line_item => :service}).where("services.organization_id IN (?)", included_cores).map{|x| x.audit_trail start_date, end_date}
    end

    @audit_trail.flatten!
    @audit_trail.compact!
    @audit_trail.sort_by!(&:created_at)
  end
end
