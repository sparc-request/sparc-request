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

class StudyTracker::CalendarsController < StudyTracker::BaseController
  before_filter :check_work_fulfillment_status, :except => [:add_note, :add_service, :delete_toast_messages]

  def show
    @study_tracker = true
    @calendar = Calendar.find(params[:id])
    @calendar.populate_on_request_edit
    @calendar.build_subject_data
    get_calendar_data(@calendar)
    generate_toasts_for_new_procedures
    @default_appointment = (@calendar.appointments_for_core(@default_core.id).reject{|x| x.completed_for_core?(@default_core.id) }.first || @calendar.appointments.first) rescue @calendar.appointments.first
    @default_visit_group_id = @default_appointment.try(:visit_group_id)
    @selected_key = "##{@default_appointment.position_switch}: #{@default_appointment.name_switch}" rescue nil

    @procedures = []
    toast_messages = ToastMessage.where(to: current_user.id, sending_class: "Procedure", message: @calendar.id.to_s)
    toast_messages.each do |toast|
      @procedures.push(Procedure.find(toast.sending_class_id))
    end
  end

  def add_note
    @appointment = Appointment.find(params[:appointment_id])
    if @appointment.notes.create(:identity_id => @user.id, :body => params[:body])
      @appointment.reload
      render :partial => 'study_tracker/calendars/notes', :locals => {:appointment => @appointment}
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@appointment.errors) }
      end
    end
  end

  def add_service
    service = Service.find(params[:service_id])
    appointment = Appointment.find(params[:appointment_id])

    #This adds the id's ONLY if they are indicated on the calendar, not just if they exist.
    existing_service_ids = appointment.procedures.select{|procedure| procedure.should_be_displayed}.collect{|procedure| procedure.direct_service.id}
    @procedures = add_individual_procedure(service, appointment, existing_service_ids, false)

    render :partial => 'new_procedure', :locals => {:appointment_index => params[:appointment_index], :procedure_index => params[:procedure_index]}
  end

  def delete_toast_messages
    toast_messages = ToastMessage.where(to: current_user.id, sending_class: "Procedure", message: params[:id])
    toast_messages.each{|toast| toast.destroy}
    render nothing: true
  end

  def change_visit_group
    params[:visit_group_id].blank? ? visit_group = nil : visit_group = VisitGroup.find(params[:visit_group_id])
    @calendar = Calendar.find(params[:calendar_id])
    get_calendar_data(@calendar)
    if visit_group
      @default_visit_group_id = visit_group.id
      @default_appointment = visit_group.appointments.first
      @selected_key = "##{@default_appointment.position_switch}: #{@default_appointment.name_switch}"
      # @default_appointment = @calendar.appointments_for_core(@default_core.id).reject{|x| x.completed_for_core?(@default_core.id) }.first || visit_group.appointments.first
      generate_toasts_for_new_procedures


    else # no visit group because appointment was completed before vg was deleted
      @default_visit_group_id = nil
      @selected_key = params[:appointment_tag]
    end
    @procedures = []
  end

  private

  def add_individual_procedure(service, appointment, existing_service_ids, recursive = true)
    return if existing_service_ids.include?(service.id)

    procedures = []
    procedures << appointment.procedures.new(:service_id => service.id)
    existing_service_ids << service.id

    service.required_services.each do |rs|
      rs_procedures = add_individual_procedure(rs, appointment, existing_service_ids)
      rs_procedures.nil? ? procedures : procedures.concat(rs_procedures)
    end

    unless recursive == true
      service.optional_services.each do |os|
        os_procedures = add_individual_procedure(os, appointment, existing_service_ids)
        os_procedures.nil? ? procedures : procedures.concat(os_procedures)
      end
    end

    return procedures
  end

  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:sub_service_request_id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end

  def get_calendar_data(calendar)
    # Get the cores
    @cwf_cores = Organization.in_cwf
    @subject = calendar.subject
    @appointments = calendar.appointments.sort{|x,y| x.position_switch <=> y.position_switch }
    @default_core = (cookies['current_core'] ? Organization.find(cookies['current_core']) : @cwf_cores.first)

    @completed_appointments = @appointments.select{|x| x.completed?}

    # Used for listing grouped totals in the dashboard
    @completed_appointments_by_visit_group = completed_appointments_by_visit_group(@completed_appointments)

    uncompleted_appointments = @appointments.reject{|x| x.completed_for_core?(@default_core.id) }
    completed_for_core = @completed_appointments.select{|x| x.completed_for_core?(@default_core.id) }
    number_of_core_appointments = @appointments.size.to_f / @cwf_cores.size.to_f

    unless number_of_core_appointments.to_f == 0.0
      if number_of_core_appointments.to_f == completed_for_core.size.to_f
        @default_appointment = completed_for_core.first
        @default_subtotal = @default_appointment.procedures.sum{|x| x.total}
      else
        @default_appointment = uncompleted_appointments.first || @appointments.first
        default_procedures = @default_appointment.procedures.select{|x| x.core == @cwf_cores.first}
        @default_subtotal = @default_appointment.completed_for_core?(@default_core.id) ? default_procedures.sum{|x| x.total} : 0.00
      end

      @default_visit_group_id = @subject.arm.visit_groups.first.id
    else
      render :partial => 'study_tracker/calendars/subject_calendar_error'
    end
  end

  # Generates a hash with visit groups as keys and arrays of appointments as values
  def completed_appointments_by_visit_group appointments
    appointments.group_by(&:visit_group_id)
  end

  def generate_toasts_for_new_procedures
    new_procedures = []
    @completed_appointments.each do |appointment|
      appointment.procedures.each do |procedure|
        if procedure.should_be_displayed && (procedure.service_id == nil)
          completion = appointment.completed_at
          if completion
            unless procedure.toasts_generated
              new_procedures << procedure
              procedure.update_attributes(:toasts_generated => true)
            end
          end
        end
      end
    end

    new_procedures.each do |procedure|
      # Add a notice ("toast message") for each new procedure
      clinical_users = ClinicalProvider.all.map{|x| x.identity} | SuperUser.all.map{|x| x.identity}
      clinical_users.each do |user|
        ToastMessage.create(:from => current_user.id, :to => user.id, :sending_class => 'Procedure', :sending_class_id => procedure.id, :message => procedure.appointment.calendar.id)
      end
    end
  end

end
