class StudyTracker::ProtocolsController < StudyTracker::BaseController
  def update
    @protocol = Protocol.find(params[:id])
    @sub_service_request =  SubServiceRequest.find(params[:sub_service_request_id])
    case @protocol.type
    when "Study" then @protocol.attributes = params[:study]
    when "Project" then @protocol.attributes = params[:project]
    end

    if @protocol.save(:validate => false)
      @protocol.arms.each do |arm|
        arm.update_attribute(:subject_count, arm.subjects.count)
      end
      redirect_to study_tracker_sub_service_request_path(@sub_service_request)
    else
      # handle errors
      redirect_to study_tracker_sub_service_request_path(@sub_service_request)
    end
  end

  def update_billing_business_manager_static_email
    @protocol = Protocol.find params[:id]

    if @protocol.update_attributes(params[:protocol])
      respond_to do |format|
        format.js { render :js => "$('.billing_business_message').removeClass('uncheck').addClass('check')" }
      end
    else
      respond_to do |format|
        format.js { render :js => "$('.billing_business_message').removeClass('check').addClass('uncheck')" }
      end
    end
  end
end
