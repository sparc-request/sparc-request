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

class Dashboard::AssociatedUsersController < Dashboard::BaseController
  layout nil
  respond_to :html, :json, :js
  
  before_filter :find_protocol_role,                              only: [:edit, :destroy]
  before_filter :find_protocol,                                   only: [:index, :new, :create, :edit, :update, :destroy]
  before_filter :find_admin_for_protocol,                         only: [:index, :new, :create, :edit, :update, :destroy]
  before_filter :protocol_authorizer_view,                        only: [:index]
  before_filter :protocol_authorizer_edit,                        only: [:new, :create, :edit, :update, :destroy]

  def index
    @protocol_roles     = @protocol.project_roles
    @permission_to_edit = @authorization.can_edit?

    respond_to do |format|
      format.json
    end
  end
  
  def edit
    @identity     = @protocol_role.identity
    @current_pi   = @protocol.primary_principal_investigator
    @header_text  = t(:dashboard)[:authorized_users][:edit][:header]

    respond_to do |format|
      format.js
    end
  end

  def new
    @header_text = t(:dashboard)[:authorized_users][:add][:header]

    if params[:identity_id] # if user selected
      @identity     = Identity.find(params[:identity_id])
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

  def create
    creator = Dashboard::AssociatedUserCreator.new(params[:project_role])

    if creator.successful?
      if @current_user_created = params[:project_role][:identity_id].to_i == @user.id
        @permission_to_edit = creator.protocol_role.can_edit?
      end

      flash.now[:success] = 'Authorized User Added!'
    else
      @errors = creator.protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    updater = Dashboard::AssociatedUserUpdater.new(id: params[:id], project_role: params[:project_role])
    
    if updater.successful?
      # We care about this because the new rights will determine what is rendered
      if @current_user_updated = params[:project_role][:identity_id].to_i == @user.id
        @protocol_type      = @protocol.type
        protocol_role       = updater.protocol_role
        @permission_to_edit = protocol_role.can_edit?

        #If the user sets themselves to member and they're not an admin, go to dashboard
        @return_to_dashboard = !(protocol_role.can_view? || @admin)
      end

      flash.now[:success] = 'Authorized User Updated!'
    else
      @errors = updater.protocol_role.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @protocol           = @protocol_role.protocol
    epic_access         = @protocol_role.epic_access
    protocol_role_clone = @protocol_role.clone
        
    @protocol_role.destroy
    
    if @current_user_destroyed = protocol_role_clone.identity_id == @user.id
      @protocol_type      = @protocol.type
      @permission_to_edit = false

      # If the user is no longer an authorized user, if they're not an admin, go to dashboard
      @return_to_dashboard = !@admin
    end

    flash.now[:alert] = 'Authorized User Removed!'

    if @protocol_role.destroyed?
      @protocol.email_about_change_in_authorized_user(@protocol_role, "destroy")
    end

    if USE_EPIC && @protocol.selected_for_epic && epic_access && !QUEUE_EPIC
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
      @protocol   = @protocol_role.protocol
    else
      protocol_id = params[:protocol_id] || params[:project_role][:protocol_id]
      @protocol   = Protocol.find(protocol_id)
    end
  end
end
