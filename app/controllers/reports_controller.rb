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
    
    ssr = SubServiceRequest.find params[:id]
    
    
  end
end
