# Copyright © 2011 MUSC Foundation for Research Development
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

class Portal::ProtocolsController < Portal::BaseController
  respond_to :html, :json

  def index
    @protocols = @user.protocols.sort_by { |pr| (pr.id || '0000') + pr.id }.reverse
    @notifications = @user.user_notifications
    #@projects = Project.remove_projects_due_to_permission(@projects, @user)

    # params[:default_project] = '0f6a4d750fd369ff4ae409373000ba69'
    if params[:default_protocol] && @protocols.map(&:id).include?(params[:default_protocol])
      protocol = @protocols.select{ |p| p.id == params[:default_protocol].to_i}[0]
      @protocols.delete(protocol)
      @protocols.insert(0, protocol)
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @protocol = Protocol.find(params[:id])
    @protocol_role = @protocol.project_roles.find_by_identity_id(@user.id)
    #@project.project_associated_users
    #@project.project_service_requests

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @protocol = Study.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
    @errors = nil
    @portal = true
    @current_step = 'protocol'
    session[:protocol_type] = 'study'
  end

  def create
    @current_step = params[:current_step]
    @protocol = Study.new(params[:study])
    @protocol.validate_nct = true
    @portal = params[:portal]
    session[:protocol_type] = 'study'
    @portal = params[:portal]

    # @protocol.assign_attributes(params[:study] || params[:project])
    if @current_step == 'go_back'
      @current_step = 'protocol'
      @protocol.populate_for_edit
    elsif @current_step == 'protocol' and @protocol.group_valid? :protocol
      @current_step = 'user_details'
      @protocol.populate_for_edit
    elsif @current_step == 'user_details' and @protocol.valid?
      @protocol.save
      @current_step = 'return_to_portal'
      if USE_EPIC
        if @protocol.selected_for_epic
          @protocol.ensure_epic_user
          if QUEUE_EPIC
            EpicQueue.create(:protocol_id => @protocol.id) unless EpicQueue.where(:protocol_id => @protocol.id).size == 1
          else
            Notifier.notify_for_epic_user_approval(@protocol).deliver
          end
        end
      end
    elsif @current_step == 'cancel_protocol'
      @current_step = 'return_to_portal'
    else
      # TODO: Is this neccessary?
      @errors = @current_step == 'protocol' ? @protocol.grouped_errors[:protocol].try(:messages) : @protocol.grouped_errors[:user_details].try(:messages)
      @protocol.populate_for_edit
    end
  end

  def update_from_fulfillment
    @protocol = Protocol.find(params[:id])
    if @protocol.update_attributes(params[:protocol])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@protocol.errors) } 
      end
    end
  end

  def edit
    @edit_protocol = true
    @protocol = Protocol.find(params[:id])
    @protocol.populate_for_edit if @protocol.type == "Study"
    respond_to do |format|
      format.html
    end
  end

  def update
    @protocol = Protocol.find(params[:id])
    attrs = params[@protocol.type.downcase.to_sym]
    if @protocol.update_attributes attrs
      flash[:notice] = "Study updated"
      redirect_to portal_root_path(:default_protocol => @protocol)
    else
      @protocol.populate_for_edit if @protocol.type == "Study"
      render :action => 'edit'
    end
  end

  def add_associated_user
    @protocol = Protocol.find(params[:id])

    @project_role = @protocol.project_roles.build(:identity_id => @user.id)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update_protocol_type
    @protocol = Protocol.find(params[:id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    # Using update_attribute here is intentional, type is a protected attribute
    if @protocol.update_attribute(:type, params[:protocol][:type])
      redirect_to portal_admin_sub_service_request_path(@sub_service_request)
    end
  end

  def view_full_calendar
    @protocol = Protocol.find(params[:id])
    @service_request = @protocol.any_service_requests_to_display?

    arm_id = params[:arm_id] if params[:arm_id]
    page = params[:page] if params[:page]
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    @tab = 'calendar'
    @portal = params[:portal]
    if @service_request
      @pages = {}
      @protocol.arms.each do |arm|
        new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
        @pages[arm.id] = @service_request.set_visit_page new_page, arm
      end
    end
    @merged = true
  end

  def change_arm
    @arm_id = params[:arm_id].to_i if params[:arm_id]
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    @selected_arm = params[:arm_id] ? Arm.find(@arm_id) : @service_request.arms.first
    @study_tracker = params[:study_tracker] == "true"
  end

  def add_arm
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    name = params[:arm_name] ? params[:arm_name] : "ARM #{@service_request.arms.count + 1}"
    visit_count = params[:visit_count] ? params[:visit_count].to_i : 1
    subject_count = params[:subject_count] ? params[:subject_count].to_i : 1

    @selected_arm = @service_request.protocol.create_arm(
        name:          name,
        visit_count:   visit_count,
        subject_count: subject_count)

    @selected_arm.default_visit_days

    @selected_arm.reload

    # If any sub service requests under this arm's protocol are in CWF we need to build patient calendars
    if @service_request.protocol.service_requests.map {|x| x.sub_service_requests.map {|y| y.in_work_fulfillment}}.flatten.include?(true)
      @selected_arm.populate_subjects
    end

    render 'portal/protocols/change_arm'
  end

  def remove_arm
    @arm_id = params[:arm_id].to_i if params[:arm_id]
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request

    Arm.find(@arm_id).destroy
    @service_request.reload

    if @service_request.arms.empty?
      @service_request.per_patient_per_visit_line_items.each(&:destroy)
    else
      @selected_arm = @service_request.arms.first
    end

    render 'portal/service_requests/add_per_patient_per_visit_visit'
  end


  private
  # TODO: Move this somewhere else. Short on time, though. - nb
  def merge_attributes(protocol, data)
    protocol.instance_values.each do |k, v|
      data.merge!({k => v}) unless data.include?(k)
    end
  end

  def fix_funding(data)
    if data["funding_status"] == "pending_funding" && data["_type"] != "project"
      data.delete("funding_source")
      data.delete("funding_source_other")
      data.delete("funding_start_date")
    elsif data["funding_status"] == "funded"
      data.delete("potential_funding_source")
      data.delete("potential_funding_source_other")
      data.delete("potential_funding_start_date")
    end
  end
end
