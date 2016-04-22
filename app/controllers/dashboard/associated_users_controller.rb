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

class Dashboard::AssociatedUsersController < Dashboard::BaseController
  layout nil

  respond_to :html, :json, :js
  before_filter :find_protocol_role, only: [:edit, :update, :destroy]
  before_filter :find_protocol, only: [:index, :show, :edit, :new, :create, :update]
  before_filter :protocol_authorizer_view, only: [:index, :show]
  before_filter :protocol_authorizer_edit, only: [:edit, :new, :create, :update]

  def index
    @protocol_roles = @protocol.project_roles
    @permission_to_edit = @authorization.can_edit?
    # @sub_service_request = SubServiceRequest.find params[:sub_service_request_id] if params[:sub_service_request_id]

    respond_to do |format|
      format.json
    end
  end

  def show
    # TODO: what does this even do?
    # TODO: is it right to call to_i here?
    # TODO: id here should be the id of a project role, not an identity
    @user = Identity.find(params[:id])
    render nothing: true # TODO: looks like there's no view for show
  end

  def edit
    @identity = @protocol_role.identity
    @current_pi = @protocol.primary_principal_investigator
    @header_text = t(:dashboard)[:authorized_users][:edit][:header]
    respond_to do |format|
      format.js
    end
  end

  def new
    if params[:identity_id] # if user selected
      @identity = Identity.find(params[:identity_id])
      @project_role = @protocol.project_roles.new(identity_id: @identity.id)
      @current_pi = @protocol.primary_principal_investigator

      unless @project_role.unique_to_protocol?
        # Adds error if user already associated with protocol
        @errors = @project_role.errors
      end

    end
    @header_text = t(:dashboard)[:authorized_users][:add][:header]
    respond_to do |format|
      format.js
    end
  end

  def create
    @protocol_role = @protocol.project_roles.build(params[:project_role])

    if @protocol_role.unique_to_protocol? && @protocol_role.fully_valid?
      if @protocol_role.role == 'primary-pi'
        @protocol.project_roles.primary_pis.each do |pr|
          pr.update_attributes(project_rights: 'request', role: 'general-access-user')
        end
      end
      @protocol_role.save
      flash.now[:success] = 'Authorized User Added!'
      if SEND_AUTHORIZED_USER_EMAILS
        @protocol.emailed_associated_users.each do |project_role|
          UserMailer.authorized_user_changed(project_role.identity, @protocol).deliver unless project_role.identity.email.blank?
        end
      end

      if USE_EPIC && @protocol.selected_for_epic && !QUEUE_EPIC
        Notifier.notify_for_epic_user_approval(@protocol).deliver
      end
    else
      @errors = @protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    @identity = @protocol_role.identity
    epic_access = @protocol_role.epic_access
    epic_rights = @protocol_role.epic_rights.clone
    @protocol_role.assign_attributes params[:project_role]

    if @protocol_role.fully_valid?
      if @protocol_role.role == 'primary-pi'
        @protocol.project_roles.where(role: 'primary-pi').where.not(identity_id: @protocol_role.identity_id).each do |pr|
          pr.update_attributes(project_rights: 'request', role: 'general-access-user')
        end
      end
      @protocol_role.save
      flash.now[:success] = 'Authorized User Updated!'
      # TODO rewrite #emailed_associated_users to return ActiveRecord::Relation, then
      # join on identities and filter out those with blank emails
      if SEND_AUTHORIZED_USER_EMAILS
        @protocol.emailed_associated_users.each do |project_role|
          UserMailer.authorized_user_changed(project_role.identity, @protocol).deliver unless project_role.identity.email.blank?
        end
      end

      if USE_EPIC && @protocol.selected_for_epic && !QUEUE_EPIC
        if epic_access && !@protocol_role.epic_access
          # Access has been removed
          Notifier.notify_for_epic_access_removal(@protocol, @protocol_role).deliver
        elsif @protocol_role.epic_access && !epic_access
          # Access has been granted
          Notifier.notify_for_epic_user_approval(@protocol).deliver
        elsif epic_rights != @protocol_role.epic_rights
          # Rights has been changed
          Notifier.notify_for_epic_rights_changes(@protocol, @protocol_role, epic_rights).deliver
        end
      end
    else
      @errors = @protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    protocol           = @protocol_role.protocol
    epic_access        = @protocol_role.epic_access
    project_role_clone = @protocol_role.clone
    @protocol_role.destroy
    flash.now[:alert] = 'Authorized User Removed!'

    if USE_EPIC && protocol.selected_for_epic && epic_access && !QUEUE_EPIC
      Notifier.notify_primary_pi_for_epic_user_removal(protocol, project_role_clone).deliver
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def search_identities
    # Like SearchController#identities, but without ssr/sr authorization
    term = params[:term].strip
    results = Identity.search(term).map { |i| { label: i.display_name, value: i.id, email: i.email } }
    results = [{ label: 'No Results' }] if results.empty?
    render json: results.to_json
  end

private
  def find_protocol_role
    @protocol_role = ProjectRole.find(params[:id])
  end

  def find_protocol
    if @protocol_role.present?
      @protocol = @protocol_role.protocol
    else
      protocol_id = params[:protocol_id] || params[:project_role][:protocol_id]
      @protocol = Protocol.find(protocol_id)
    end
  end
end
