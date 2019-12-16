# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  before_action :find_protocol_role,        only: [:edit, :destroy]
  before_action :find_protocol,             only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :find_admin_for_protocol,   only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :protocol_authorizer_view,  only: [:index]
  before_action :protocol_authorizer_edit,  only: [:new, :create, :edit, :update, :destroy]

  def index
    @protocol_roles     = @protocol.project_roles
    @permission_to_edit = @authorization.can_edit?

    respond_to :json
  end

  def new
    controller          = ::AssociatedUsersController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.new
    @identity       = controller.instance_variable_get(:@identity)
    @protocol_role  = controller.instance_variable_get(:@protocol_role)
    @epic_user      = controller.instance_variable_get(:@epic_user)
    @errors         = controller.instance_variable_get(:@errors)

    respond_to :js
  end

  def create
    controller          = ::AssociatedUsersController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.create
    @protocol_role      = controller.instance_variable_get(:@protocol_role)
    @permission_to_edit = @protocol_role.can_edit?
    @errors             = controller.instance_variable_get(:@errors)
    respond_to :js
  end

  def edit
    controller          = ::AssociatedUsersController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.instance_variable_set(:@protocol_role, @protocol_role)
    controller.edit
    @identity       = controller.instance_variable_get(:@identity)
    @protocol_role  = controller.instance_variable_get(:@protocol_role)
    @epic_user      = controller.instance_variable_get(:@epic_user)
    respond_to :js
  end

  def update
    updater             = AssociatedUserUpdater.new(id: params[:id], project_role: project_role_params, current_identity: current_user)
    @protocol_role      = updater.protocol_role
    @permission_to_edit = @protocol_role.can_edit?

    if updater.successful?
      flash[:success] = t('authorized_users.updated')
    else
      @errors = updater.protocol_role.errors
    end

    respond_to :js
  end

  def destroy
    @current_user_destroyed = @protocol_roles.where(identity: current_user).any?
    @protocol_roles.each{ |pr| EpicQueueManager.new(@protocol, current_user, pr).create_epic_queue }
    Notifier.notify_primary_pi_for_epic_user_removal(@protocol, @protocol_roles).deliver if is_epic?
    @protocol.email_about_change_in_authorized_user(@protocol_roles, "destroy")
    @protocol_roles.destroy_all

    if @current_user_destroyed
      @permission_to_edit = false
    end

    flash[:alert] = t(:authorized_users)[:destroyed]

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
      else
        Protocol.find(params[:protocol_id] || project_role_params[:protocol_id])
      end
  end

  def is_epic?
    Setting.get_value("use_epic") && !Setting.get_value("queue_epic") && @protocol.selected_for_epic && @protocol_roles.where(epic_access: true).any?
  end
end
