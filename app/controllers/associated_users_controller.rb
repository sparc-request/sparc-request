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

  before_action :initialize_service_request,  except: [:update_professional_organizations]
  before_action :authorize_identity,          except: [:update_professional_organizations]
  before_action :find_protocol_role,          only: [:edit, :destroy]
  before_action :find_protocol,               only: [:index, :new, :edit, :destroy]

  def index
    @protocol_roles = @protocol.project_roles

    respond_to :json
  end

  def new
    if params[:identity_id] # if user selected
      @identity = Identity.find_or_create(params[:identity_id])

      if Setting.get_value("use_epic") && Setting.get_value("validate_epic_users") && @protocol.selected_for_epic
        @epic_user = EpicUser.for_identity(@identity)
      end

      @protocol_role = @protocol.project_roles.new(identity_id: @identity.id)

      unless @protocol_role.unique_to_protocol?
        @errors = @protocol_role.errors
      end
    end

    respond_to :js
  end

  def create
    creator         = AssociatedUserCreator.new(project_role_params, current_user)
    @protocol_role  = creator.protocol_role

    if creator.successful?
      flash[:success] = t('authorized_users.created')
    else
      @errors = creator.protocol_role.errors
    end

    respond_to :js
  end

  def edit
    @identity = @protocol_role.identity

    if Setting.get_value("use_epic") && Setting.get_value("validate_epic_users") && @protocol != nil && @protocol.selected_for_epic
      @epic_user = EpicUser.for_identity(@identity)
    end

    respond_to :js
  end

  def update
    updater         = AssociatedUserUpdater.new(id: params[:id], project_role: project_role_params, current_identity: current_user)
    @protocol_role  = updater.protocol_role

    if updater.successful?
      flash[:success] = t('authorized_users.updated')
    else
      @errors = @protocol_role.errors
    end

    respond_to :js
  end

  def destroy
    @redirect = @protocol_roles.where(identity: current_user).any? && !current_user.catalog_overlord?
    @protocol_roles.each{ |pr| EpicQueueManager.new(@protocol, current_user, pr).create_epic_queue }
    Notifier.notify_primary_pi_for_epic_user_removal(@protocol, @protocol_roles).deliver if is_epic?
    @protocol.email_about_change_in_authorized_user(@protocol_roles, "destroy")
    @protocol_roles.destroy_all

    flash[:alert] = t(:authorized_users)[:destroyed]

    respond_to :js
  end

  def update_professional_organizations
    @professional_organization = ProfessionalOrganization.find_by_id(params[:last_selected_id])

    respond_to :js
  end

  private

  def project_role_params
    if params[:project_role][:identity_attributes]
      params[:project_role][:identity_attributes][:phone] = sanitize_phone params[:project_role][:identity_attributes][:phone]
    end

    params[:project_role][:project_rights] ||= ""

    params.require(:project_role).permit(
      :epic_access,
      :identity_id,
      :project_rights,
      :protocol_id,
      :role,
      :role_other,
      epic_rights_attributes: [
        :new,
        :position,
        :right,
        :_destroy
      ],
      identity_attributes: [
        :credentials,
        :credentials_other,
        :email,
        :era_commons_name,
        :id,
        :orcid,
        :phone,
        :professional_organization_id,
        :subspecialty
      ]
    )
  end

  def find_protocol_role
    if /^[0-9]+$/ =~ params[:id]
      @protocol_role  = ProjectRole.find(params[:id])
      @protocol_roles = ProjectRole.where(id: @protocol_role)
    else
      @protocol_roles = ProjectRole.where(id: params[:id].split(','))
    end
  end

  def find_protocol
    @protocol = 
      if @protocol_role.present?
        @protocol_role.protocol
      elsif @protocol_roles.present?
        @protocol_roles.first.protocol
      elsif @service_request
        @protocol = @service_request.protocol
      else
        Protocol.find(params[:protocol_id] || project_role_params[:protocol_id])
      end
  end

  def is_epic?
    Setting.get_value("use_epic") && !Setting.get_value("queue_epic") && @protocol.selected_for_epic? && @protocol_roles.where(epic_access: true).any?
  end
end
