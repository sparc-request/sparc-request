# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class AssociatedUsersController < ApplicationController
  respond_to :html, :json, :js

  before_action :initialize_service_request
  before_action :authorize_identity
  before_action :find_protocol_role,          only: [:edit, :destroy]
  before_action :find_protocol,               only: [:index, :new, :edit, :destroy]

  def index
    @current_user   = current_user
    @protocol_roles = @protocol.project_roles

    respond_to do |format|
      format.json
    end
  end

  def new
    @header_text  = t(:authorized_users)[:add][:header]
    @dashboard    = false

    if params[:identity_id] # if user selected
      @identity = Identity.find_or_create(params[:identity_id])

      if Setting.get_value("use_epic") && Setting.get_value("validate_epic_users") && @protocol != nil && @protocol.selected_for_epic
        @epic_user = EpicUser.for_identity(@identity)
      end

      @project_role = @protocol.project_roles.new(identity_id: @identity.id)
      @current_pi   = @protocol.primary_principal_investigator

      unless @project_role.unique_to_protocol?
        # Adds error if user already associated with protocol
        @errors = @project_role.errors
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def edit
    @identity = @protocol_role.identity

    if Setting.get_value("use_epic") && Setting.get_value("validate_epic_users") && @protocol != nil && @protocol.selected_for_epic
      @epic_user = EpicUser.for_identity(@identity)
    end

    @header_text  = t(:authorized_users)[:edit][:header]
    @dashboard    = false
    @admin        = false

    respond_to do |format|
      format.js
    end
  end

  def create
    creator = AssociatedUserCreator.new(project_role_params, current_user)

    if creator.successful?
      flash.now[:success] = t(:authorized_users)[:created]
    else
      @errors = creator.protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    updater               = AssociatedUserUpdater.new(id: params[:id], project_role: project_role_params, current_identity: current_user)
    protocol_role         = updater.protocol_role
    @return_to_dashboard  = protocol_role.identity_id == current_user.id && ['none', 'view'].include?(protocol_role.project_rights)

    if updater.successful?
      flash.now[:success] = t(:authorized_users)[:updated]
    else
      @errors = updater.protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    epic_access         = @protocol_role.epic_access
    protocol_role_clone = @protocol_role.clone
    epic_queue_manager = EpicQueueManager.new(
      @protocol_role.protocol, current_user, @protocol_role
    )
    epic_queue_manager.create_epic_queue

    @protocol_role.destroy

    flash.now[:alert] = t(:authorized_users)[:destroyed]

    if Setting.get_value("use_epic") && @protocol.selected_for_epic && epic_access && !Setting.get_value("queue_epic")
      Notifier.notify_primary_pi_for_epic_user_removal(@protocol, protocol_role_clone).deliver
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def search_identities
    # Like SearchController#identities, but without ssr/sr authorization
    term    = params[:term].strip
    results = Identity.search(term).map { |i| { label: i.display_name, value: i.suggestion_value, email: i.email } }
    results = [{ label: 'No Results' }] if results.empty?

    render json: results.to_json
  end

private
  def project_role_params
    params.require(:project_role).permit(:protocol_id,
      :identity_id,
      :project_rights,
      :role,
      :role_other,
      :epic_access,
      identity_attributes: [
        :orcid,
        :credentials,
        :credentials_other,
        :email,
        :era_commons_name,
        :professional_organization_id,
        :phone,
        :subspecialty,
        :id
      ],
      epic_rights_attributes: [:right,
        :new,
        :position,
        :_destroy])
  end

  def find_protocol_role
    @protocol_role = ProjectRole.find(params[:id])
  end

  def find_protocol
    if @protocol_role.present?
      @protocol   = @protocol_role.protocol
    else
      protocol_id = params[:protocol_id] || project_role_params[:protocol_id]
      @protocol   = Protocol.find(protocol_id)
    end
  end
end
