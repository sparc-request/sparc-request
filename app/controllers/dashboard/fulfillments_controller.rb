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

class Dashboard::FulfillmentsController < Dashboard::BaseController
  before_action :authorize_admin
  before_action :find_fulfillment, only: [:edit, :update, :destroy]

  def index
    @line_item = LineItem.find(params[:line_item_id])

    respond_to do |format|
      format.js
      format.json {
        @fulfillments = @line_item.fulfillments
      }
    end
  end

  def new
    @line_item    = LineItem.find(params[:line_item_id])
    @fulfillment  = @line_item.fulfillments.new
  end

  def create
    @fulfillment = Fulfillment.new(fulfillment_params)

    if @fulfillment.save
      @line_item = @fulfillment.line_item
      flash[:success] = t('dashboard.sub_service_requests.study_level_activities.fulfillments.created')
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
  end

  def update
    if @fulfillment.update_attributes(fulfillment_params)
      @line_item = @fulfillment.line_item
      flash[:success] = t('dashboard.sub_service_requests.study_level_activities.fulfillments.updated')
    else
      @errors = @fulfillment.errors
    end
  end

  def destroy
    if @fulfillment.delete
      @line_item = @fulfillment.line_item
      flash[:alert] = t('dashboard.sub_service_requests.study_level_activities.fulfillments.deleted')
    end
  end

  private

  def find_fulfillment
    @fulfillment = Fulfillment.find(params[:id])
  end

  def fulfillment_params
    params[:fulfillment][:date] = sanitize_date params[:fulfillment][:date]

    params.require(:fulfillment).permit(
      :line_item_id,
      :date,
      :time,
      :timeframe
    )
  end
end
