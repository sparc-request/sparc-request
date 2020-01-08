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
  before_action :initialize_service_request,  unless: :in_dashboard?
  before_action :authorize_identity,          unless: :in_dashboard?
  before_action :authorize_admin,             if: :in_dashboard?

  def edit
    @line_item = LineItem.find(params[:id])

    respond_to :js
  end

  def update
    @line_item  = LineItem.find(params[:id])
    @field      = params[:field]

    if @line_item.displayed_cost_valid?(line_item_params[:displayed_cost]) && @line_item.update_attributes(line_item_params)
      if @field != 'displayed_cost'
        @service_request.update_attribute(:status, 'draft') unless @service_request.previously_submitted?
        @line_item.sub_service_request.update_attribute(:status, 'draft')
      end
    else
      @errors = @line_item.errors
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
