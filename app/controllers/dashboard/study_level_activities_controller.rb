# Copyright © 2011-2020 MUSC Foundation for Research Development
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

class Dashboard::StudyLevelActivitiesController < Dashboard::BaseController
  before_action :authorize_admin
  before_action :find_line_item, only: [:show, :edit, :update, :destroy]

  def index
    @line_items = @sub_service_request.one_time_fee_line_items

    respond_to :json
  end

  def show
    respond_to :js
  end

  def new
    @line_item  = params[:line_item] ? @service_request.line_items.new(line_item_params) : @service_request.line_items.new
    
    respond_to :js
  end

  def create
    @line_item = @service_request.line_items.new(line_item_params)
    ssr = @line_item.sub_service_request

    if @line_item.save
      flash[:success] = t('dashboard.sub_service_requests.study_level_activities.created')
      if @line_item.service.one_time_fee && ssr.imported_to_fulfillment?
        FulfillmentSynchronization.create(sub_service_request_id: ssr.id, line_item_id: @line_item.id, action: 'create')
        ssr.synch_to_fulfillment = true
        ssr.save(validate: false)
      end
    else
      @errors = @line_item.errors
    end

    respond_to :js
  end

  def edit
    @line_item.service_id = line_item_params[:service_id] if params[:line_item] && line_item_params[:service_id]

    respond_to :js
  end

  def update
    if @line_item.update_attributes(line_item_params)
      ssr = @line_item.sub_service_request
      if @line_item.service.one_time_fee && ssr.imported_to_fulfillment?
        FulfillmentSynchronization.create(sub_service_request_id: ssr.id, line_item_id: @line_item.id, action: 'update')
        ssr.synch_to_fulfillment = true
        ssr.save(validate: false)
      end
      flash[:success] = t('dashboard.sub_service_requests.study_level_activities.updated')
    else
      @errors = @line_item.errors
    end
  end

  def destroy
    if !has_cwf_fulfillments?(@line_item)
      ssr = @line_item.sub_service_request
      if @line_item.service.one_time_fee && ssr.imported_to_fulfillment? 
        FulfillmentSynchronization.create(sub_service_request_id: ssr.id, line_item_id: @line_item.id, action: 'destroy')
        ssr.synch_to_fulfillment = true
        ssr.save(validate: false)
      end
      @line_item.destroy
      flash[:alert] = t('dashboard.sub_service_requests.study_level_activities.destroyed')
    else
      flash[:alert] = t('dashboard.sub_service_requests.study_level_activities.not_destroyed')
    end
  end

  private

  def line_item_params
    params.require(:line_item).permit(
      :service_request_id,
      :sub_service_request_id,
      :service_id,
      :optional,
      :complete_date,
      :in_process_date,
      :units_per_quantity,
      :quantity,
      :displayed_cost,
      fulfillments_attributes: [
        :line_item_id,
        :timeframe,
        :notes,
        :time,
        :date,
        :quantity,
        :unit_quantity,
        :quantity_type,
        :unit_type,
        :formatted_date,
        :_destroy
      ]
    )
  end

  def find_line_item
    @line_item = LineItem.find(params[:id])
  end

  def has_cwf_fulfillments?(line_item)
    if Setting.get_value("fulfillment_contingent_on_catalog_manager")
      cwf_line_item = Shard::Fulfillment::LineItem.where(sparc_id: line_item.id).first
      (cwf_line_item && cwf_line_item.fulfillments.size > 0) ? true : false
    else
      false
    end
  end
end
