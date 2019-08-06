# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class Funding::ServicesController < ApplicationController
  layout "funding"
  protect_from_forgery

  before_action :authenticate_identity!
  before_action :authorize_funding_admin
  before_action :find_funding_opp,  only: [:show]

  def set_highlighted_link
    @highlighted_link = 'sparc_funding'
  end

  def index
    respond_to do |format|
      format.html
      format.json{
        @services = Service.funding_opportunities
        @user = current_user
      }
    end
  end

  def show
    @service = Service.find(params[:id])
  end

  def documents
    @table = params[:table]
    @service_id = params[:id]
    @funding_documents = Document.joins(sub_service_requests: {line_items: :service}).where(services: {id: @service_id}, doc_type: @table).distinct
  end

  private
  def find_funding_opp
    unless @service = Service.exists?(id: params[:id], organization_id: Setting.get_value("funding_org_ids"))
      flash[:alert] = t(:funding)[:flash_message][:not_found]
      redirect_to funding_root_path
    end
  end

end