class ReportsController < ApplicationController
  def research_project_summary
    @service_request = ServiceRequest.find params[:id]
    respond_to do |format|
      format.xlsx do
        render xlsx: "research_project_summary", filename: "research_project_summary.xlsx", disposition: "inline"
      end
    end
  end
end
