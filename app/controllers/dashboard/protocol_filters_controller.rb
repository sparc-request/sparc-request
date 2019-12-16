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

class Dashboard::ProtocolFiltersController < Dashboard::BaseController
  respond_to :html, :json

  def new
    @protocol_filter = current_user.protocol_filters.new(filterrific_params)
  end

  def create
    protocol_filter = current_user.protocol_filters.create(create_params)

    if protocol_filter.save
      flash[:success] = 'Search Saved!'
    else
      @errors = protocol_filter.errors
    end

    @protocol_filters = ProtocolFilter.latest_for_user(current_user.id, ProtocolFilter::MAX_FILTERS)
  end

  def destroy
    filter = ProtocolFilter.find(params[:id])
    filter.destroy
    @protocol_filters = ProtocolFilter.latest_for_user(current_user.id, ProtocolFilter::MAX_FILTERS)
    
    flash[:alert] = 'Search Deleted!'
    
    respond_to do |format|
      format.js
    end
  end

  private

  def filterrific_params
    params.require(:filterrific).permit(:identity_id,
      :search_name,
      :show_archived,
      :admin_filter,
      :search_query,
      :reset_filterrific,
      search_query: [:search_drop, :search_text],
      with_organization: [],
      with_status: [],
      with_owner: [])
  end

  def create_params
    params.require(:protocol_filter).permit(
      :search_name,
      :show_archived,
      :admin_filter,
      :search_query,
      with_organization: [],
      with_status: [],
      with_owner: [])
  end
end
