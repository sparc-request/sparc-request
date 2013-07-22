class ReportsController < ApplicationController
  def research_project_summary
    @sub_service_request = SubServiceRequest.find params[:id]
    @service_request = @sub_service_request.service_request 
    @protocol = @service_request.protocol

    respond_to do |format|
      format.xlsx do
        render xlsx: "research_project_summary", filename: "research_project_summary.xlsx", disposition: "inline"
      end
    end
  end
end
