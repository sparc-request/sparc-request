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

class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  helper :all

  helper_method :current_user
  helper_method :xeditable?

  before_action :preload_settings
  before_action :set_highlighted_link  # default is to not highlight a link
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def preload_settings
    Setting.preload_values
  end

  def not_signed_in?
    !current_user.present?
  end

  def redirect_to_login
    flash[:alert] = t(:devise)[:failure][:unauthenticated]
    redirect_to identity_session_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path(srid: @service_request.try(:id))
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def set_highlighted_link  # default value, override inside controllers
    @highlighted_link ||= ''
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit!}
  end

  def current_user
    current_identity
  end

  def check_rmid_server_status
    if Setting.get_value("research_master_enabled") && (@rmid_server_down = !Protocol.rmid_status)
      flash[:alert] = t(:protocols)[:summary][:tooltips][:rmid_server_down]
    end
  end

  def authorization_error msg, ref
    error = msg
    error += "<br />If you believe this is in error please contact, #{I18n.t 'error_contact'}, and provide the following information:"
    error += "<br /> Reference #: "
    error += ref

    render partial: 'service_requests/authorization_error', locals: { error: error }
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end

  def clean_messages errors
    errors.map {|k,v| v}.flatten
  end

  def initialize_service_request
    if params[:srid].present?
      @service_request = ServiceRequest.find(params[:srid])
    elsif action_name == 'add_service'
      @service_request = ServiceRequest.new(status: 'first_draft')
      @service_request.save(validate: false)
    else
      @service_request = ServiceRequest.new(status: 'first_draft')
    end
  end

  def authorize_identity
    # can the user edit the service request
    # we have a current user
    if @service_request.status == 'first_draft'
      return true
    elsif current_user && current_user.can_edit_service_request?(@service_request)
      return true
    elsif not_signed_in?
      authenticate_identity!
      return true
    end

    authorization_error "The service request you are trying to access is not editable.", "SR#{params[:id]}"
  end

  def in_dashboard?
    (params[:portal] && params[:portal] == 'true') || (params[:admin] && params[:admin] == 'true')
  end

  def authorize_dashboard_access
    if params[:sub_service_request_id]
      authorize_admin
    else
      if params[:service_request_id]
        @service_request = ServiceRequest.find(params[:service_request_id])
      end
      authorize_protocol
    end
  end

  def authorize_protocol
    @protocol           = @service_request ? @service_request.protocol : Protocol.find(params[:protocol_id])
    permission_to_view  = current_user.can_view_protocol?(@protocol)

    unless permission_to_view || Protocol.for_admin(current_user.id).include?(@protocol)
      @protocol = nil

      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def authorize_admin
    if not_signed_in?
      redirect_to_login
    else
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      @service_request     = @sub_service_request.service_request
      unless (current_user.authorized_admin_organizations & @sub_service_request.org_tree).any?
        @sub_service_request = nil
        @service_request = nil
        render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
      end
    end
  end

  def find_locked_org_ids
    @locked_org_ids = []
    if @service_request.protocol.present?
      @service_request.sub_service_requests.each do |ssr|
        if ssr.is_locked?
          @locked_org_ids << ssr.organization_id
          @locked_org_ids << ssr.organization.all_child_organizations_with_self.map(&:id)
        end
      end

      unless @locked_org_ids.empty?
        @locked_org_ids = @locked_org_ids.flatten.uniq
      end
    end
  end

  def xeditable? object=nil
    true
  end

  def authorize_funding_admin
    redirect_to root_path unless Setting.get_value("use_funding_module") && current_user.is_funding_admin?
  end

  def sanitize_dates(params, field_names)
    attrs = {}
    params.each do |k, v|
      if field_names.include?(k.to_sym)
        attrs[k] = v.blank? ? v : Date.strptime(v, '%m/%d/%Y')
      else
        attrs[k] = v
      end
    end

    attrs
  end
end
