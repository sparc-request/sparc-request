# Copyright © 2011-2017 MUSC Foundation for Research Development
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

  def set_highlighted_link
    @highlighted_link ||= 'sparc_catalog'
  end

  def current_user
    current_identity
  end

  def authorize_survey_builder_access
    # If SystemSurvey-specific actions, verify the user is a Site Admin
    if params[:type] && params[:type] == 'SystemSurvey'
      unless current_user.is_site_admin?
        raise ActionController::RoutingError.new('Not Found')
      end
    # If Form-specific actions, verify the user is a Super User, Service Provider, or Overlord
    elsif params[:type] && params[:type] == 'Form'
      unless current_user.is_super_user? || current_user.is_service_provider? || current_user.is_overlord?
        raise ActionController::RoutingError.new('Not Found')
      end
    # If non-specific actions, verify the user is a Site Admin, Super User, Service Provider, or Overlord
    else
      unless current_user.is_site_admin? || current_user.is_super_user? || current_user.is_service_provider? || current_user.is_overlord?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
