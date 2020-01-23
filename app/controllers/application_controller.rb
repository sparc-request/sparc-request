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
  include ActionView::Helpers::TextHelper

  protect_from_forgery prepend: true

  helper :all

  helper_method :current_user

  around_action :select_shard

  before_action :preload_database_values
  before_action :set_highlighted_link
  before_action :configure_permitted_params,  if: :devise_controller?

  protected

  def select_shard(&block)
    if identity_signed_in?
      Octopus.using(current_user.shard_identifier, &block)
    elsif devise_controller? && resource_params && resource_params['ldap_uid']
      Octopus.using(Identity.shard_identifier(resource_params['ldap_uid']), &block)
    else
      yield
    end
  end

  ##############################
  ### Devise-Related Methods ###
  ##############################

  def current_user
    current_identity
  end

  def redirect_to_login
    flash[:alert] = t(:devise)[:failure][:unauthenticated]
    redirect_to identity_session_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def configure_permitted_params
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit! }
  end

  #############################
  ### Before-Action Methods ###
  #############################

  def preload_database_values
    Setting.preload_values

    if identity_signed_in?
      PermissibleValue.preload_values
    end
  end

  def set_highlighted_link  # default value, override inside controllers
    @highlighted_link ||= ''
  end

  #####################
  ### Other Methods ###
  #####################

  def authorization_error(msg=t('error_pages.authorization_error.error'), ref=nil)
    error   = msg + t('error_pages.authorization_error.contact', email: Setting.get_value('contact_us_cc'))
    error  += t('error_pages.authorization_error.reference', ref: ref) if ref

    redirect_to authorization_error_path(error: error, format: request.format.html? ? :html : :js)
  end

  def initialize_service_request
    if params[:srid].present?
      @service_request = ServiceRequest.find(params[:srid])
    elsif identity_signed_in?
      @service_request = ServiceRequest.new(status: 'first_draft')
    end
  end

  def authorize_identity
    if (@service_request.nil? || @service_request.new_record?) && action_name == 'catalog' || (helpers.request_referrer_action == 'catalog' && !request.format.html?)
      # The user is viewing the catalog without starting a request
      return true
    elsif identity_signed_in? && (@service_request.new_record? || current_user.can_edit_service_request?(@service_request))
      return true
    elsif !identity_signed_in?
      store_location_for(:identity, request.get? && request.format.html? ? request.url : request.referrer)
      authenticate_identity!
    end

    authorization_error("The service request you are trying to access is not editable.", "SR#{params[:id]}")
  end

  def in_dashboard?
    @in_dashboard ||= helpers.in_dashboard?

    in_admin?

    @in_dashboard
  end

  def in_admin?
    @in_admin ||= helpers.in_admin?
  end

  def authorize_dashboard_access
    if params[:ssrid]
      authorize_admin
    else
      authorize_protocol
    end
  end

  def authorize_protocol
    @service_request    = ServiceRequest.find(params[:srid]) if params[:srid]
    @protocol           = @service_request ? @service_request.protocol : Protocol.find(params[:protocol_id])
    permission_to_view  = current_user.can_view_protocol?(@protocol)

    unless permission_to_view || Protocol.for_admin(current_user.id).include?(@protocol)
      authorization_error('You are not allowed to access this Sub Service Request.')
    end
  end

  def authorize_admin
    if current_user
      @sub_service_request ||= SubServiceRequest.find(params[:ssrid])
      @service_request     = @sub_service_request.service_request
      unless (current_user.authorized_admin_organizations & @sub_service_request.org_tree).any?
        authorization_error('You are not allowed to access this Sub Service Request.')
      end
    else
      redirect_to_login
    end
  end

  def authorize_overlord
    if current_user
      unless current_user.catalog_overlord?
        authorization_error
      end
    else
      redirect_to_login
    end
  end

  def authorize_funding_admin
    redirect_to root_path unless Setting.get_value("use_funding_module") && current_user.is_funding_admin?
  end

  def sanitize_date(date)
    return Date.strptime(date, '%m/%d/%Y').to_s rescue Date.strptime(date, '%Y-%m-%d').to_s rescue ""
  end

  def sanitize_phone(phone)
    return phone.gsub(/\(|\)|-|\s/, '').gsub(I18n.t('constants.phone.extension'), '#') rescue ""
  end

  # More Specific Helpers #

  def setup_calendar_pages
    @pages  = {}
    @page   = params[:page].try(:to_i) || 1
    arm_id  = params[:arm_id].to_i if params[:arm_id]
    @arm    = Arm.find(arm_id) if arm_id

    session[:service_calendar_pages]          = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id]  = @page if @page && arm_id

    @service_request.arms.each do |arm|
      new_page        = (session[:service_calendar_pages].nil? || session[:service_calendar_pages][arm.id].nil?) ? 1 : session[:service_calendar_pages][arm.id]
      @pages[arm.id]  = @service_request.set_visit_page(new_page, arm)
    end
  end

  def find_locked_org_ids
    @locked_org_ids = identity_signed_in? ? @service_request.sub_service_requests.eager_load(organization: { org_children: :org_children }).select(&:is_locked?).reject(&:is_complete?).map{ |ssr| [ssr.organization_id, ssr.organization.all_child_organizations_with_self.map(&:id)] }.flatten.uniq : []
  end
end
