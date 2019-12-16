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

class Surveyor::BaseController < ApplicationController
  protect_from_forgery
  helper_method :current_user

  before_action :authenticate_identity!
  before_action :set_highlighted_link

  protected

  def set_highlighted_link
    @highlighted_link ||= 'sparc_catalog'
  end

  def authorize_survey_builder_access
    # If SystemSurvey-specific actions, verify the user is a Site Admin
    if params[:type] && params[:type] == 'SystemSurvey' && !user_has_survey_access?
      raise ActionController::RoutingError.new('Not Found')
    # If any other actions, verify the user is a Site Admin, Super User, Service Provider, or Catalog Manager
    elsif !user_has_survey_access? && !user_has_form_access?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def user_has_survey_access?
    current_user.is_site_admin?
  end

  def user_has_form_access?
    if params[:type] == 'Form' && params[:id]
      Form.for(current_user).where(id: params[:id]).any?
    else
      current_user.is_super_user? || current_user.is_service_provider? || current_user.is_catalog_manager?
    end
  end
end
