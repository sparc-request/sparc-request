class StudyTracker::SubjectsController < StudyTracker::BaseController
  def update
    @subject = Subject.find(params[:id])
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
    clinical_users = ClinicalProvider.where("identity_id != ?", current_user.id).includes(:identity).collect{|x| x.identity}

    new_procedures.each do |procedure|
      associated_users.uniq.each do |user|
        UserMailer.subject_procedure_notification(user.identity, procedure, @sub_service_request).deliver
      end
    end

    backdated_procedures =  new_procedures.empty? ? [] : new_procedures.select{|x| x.appointment.completed_for_core?(x.core.id)}

    unless backdated_procedures.empty?
      backdated_procedures.each do |procedure|
        ##Add a notice ("toast message") for each new procedure
        clinical_users.each do |user|
          ToastMessage.create(:from => current_user.id, :to => user.id, :sending_class => "Procedure", :sending_class_id => procedure.id, :message => procedure.appointment.calendar.id)
        end
      end
    end
  end

end
