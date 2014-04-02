class StudyTracker::SubjectsController < StudyTracker::BaseController
  def update
    @subject = Subject.includes(:calendar).find(params[:id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @procedures = @subject.procedures

    if @subject.update_attributes(params[:subject])
      calculate_new_procedures

      redirect_to study_tracker_sub_service_request_calendar_path(@sub_service_request, @subject.calendar)
    else
      # handle errors
      redirect_to study_tracker_sub_service_request_calendar_path(@sub_service_request, @subject.calendar)
    end
  end


  private
  def calculate_new_procedures
    ##Creating array of new procedures, but only procedures with a completed appointment for that procedure's core.
    new_procedures = @subject.procedures - @procedures


    @protocol = @subject.arm.protocol
    associated_users = @protocol.emailed_associated_users << @protocol.primary_pi_project_role

    # Disabled (potentially only temporary) as per Lane
    # new_procedures.each do |procedure|
    #   associated_users.uniq.each do |user|
    #     UserMailer.subject_procedure_notification(user.identity, procedure, @sub_service_request).deliver
    #   end
    # end
  end
end
