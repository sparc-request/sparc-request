# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
