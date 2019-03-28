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

class LineItemsController < ApplicationController
  respond_to :json, :js, :html

  before_action :initialize_service_request
  before_action :authorize_identity

  # Used for x-editable update and validations
  def update
    line_item = LineItem.find(params[:id])

    if line_item.update_attributes(line_item_params)
      @service_request.update_attribute(:status, 'draft')
      line_item.sub_service_request.update_attribute(:status, 'draft')
      
      render json: {
        total_per_study: render_to_string(partial: 'service_calendars/master_calendar/otf/total_per_study', locals: { line_item: line_item }),
        max_total_direct: render_to_string(partial: 'service_calendars/master_calendar/otf/totals/max_total_direct_one_time_fee', locals: { service_request: @service_request }),
        total_costs: render_to_string(partial: 'service_calendars/master_calendar/otf/totals/total_cost_per_study', locals: { service_request: @service_request })
      }
    else
      render json: line_item.errors, status: :unprocessable_entity
    end
  end

  private

  def line_item_params
    @line_item_params ||= params.require(:line_item).
      permit(:service_request_id,
        :sub_service_request_id,
        :service_id,
        :optional,
        :complete_date,
        :in_process_date,
        :units_per_quantity,
        :quantity,
        :displayed_cost,
        fulfillments_attributes: [:line_item_id,
          :timeframe,
          :notes,
          :time,
          :date,
          :quantity,
          :unit_quantity,
          :quantity_type,
          :unit_type,
          :formatted_date,
          :_destroy])
  end
end
