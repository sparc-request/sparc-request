class StudyTracker::SubjectsController < StudyTracker::BaseController
  def update
    @subject = Subject.find(params[:id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])

    if @subject.update_attributes(params[:subject])
      redirect_to study_tracker_sub_service_request_calendar_path(@sub_service_request, @subject.calendar)
    else
      # handle errors
      redirect_to study_tracker_sub_service_request_calendar_path(@sub_service_request, @subject.calendar)
    end
  end
end
