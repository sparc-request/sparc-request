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

class Surveyor::ResponseFiltersController < ApplicationController
  respond_to :html, :js

  before_action :authenticate_identity!

  def new
    @response_filter = current_user.response_filters.new(sanitize_dates(new_params, [:start_date, :end_date]))
  end

  def create
    @response_filter = current_user.response_filters.new(create_params)

    if @response_filter.save
      fix_dates_for_saved_searches(@response_filter)
      flash[:success] = t(:surveyor)[:response_filters][:created]
    else
      @errors = @response_filter.errors
    end
  end

  def destroy
    @response_filter = ResponseFilter.find(params[:id])
    
    @response_filter.destroy

    flash[:alert] = t(:surveyor)[:response_filters][:destroyed]
  end

  private

  def new_params
    params.require(:filterrific).permit(
      :of_type,
      :start_date,
      :end_date,
      :include_incomplete,
      with_state: [],
      with_survey: []
    )
  end

  def create_params
    params.require(:response_filter).permit(
      :name,
      :identity_id,
      :of_type,
      :start_date,
      :end_date,
      :include_incomplete,
      with_state: [],
      with_survey: []
    )
  end

  def fix_dates_for_saved_searches(response_filter)
    response_filter.update_attributes(
      start_date: response_filter.start_date.to_date.try(:strftime, '%m/%d/%Y'),
      end_date: response_filter.end_date.to_date.try(:strftime, '%m/%d/%Y')
    )
  end

end

