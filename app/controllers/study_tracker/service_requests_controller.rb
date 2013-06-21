class StudyTracker::ServiceRequestsController < StudyTracker::BaseController
  def update
    @service_request = ServiceRequest.find(params[:id])
    @sub_service_request =  SubServiceRequest.find(params[:sub_service_request_id])
    @service_request.attributes = params[:service_request]

    if @service_request.save(:validate => false)
      ##If we have deleted, or added a subject, update the arm.subject_count
      @service_request.arms.each do |arm|
        arm.update_attribute(:subject_count, arm.subjects.count)
      end
      redirect_to study_tracker_sub_service_request_path(@sub_service_request)
    else
      # handle errors
      redirect_to study_tracker_sub_service_request_path(@sub_service_request)
    end
  end
end
