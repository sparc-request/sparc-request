# Copyright © 2011-2016 MUSC Foundation for Research Development
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

class Dashboard::LineItemsController < Dashboard::BaseController
  respond_to :json, :js, :html
  before_action :find_line_item, only: [:edit, :update, :destroy, :details]

  def index
    respond_to do |format|
      format.json do
        @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
        @line_items = @sub_service_request.one_time_fee_line_items

        render
      end
    end
  end

  def new
    # called to render modal to create line items
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    if params[:one_time_fee]
      @line_item = LineItem.new(sub_service_request_id: @sub_service_request.id, service_request_id: @service_request.id)
      @header_text = t(:dashboard)[:study_level_activities][:add]
    else
      @services = @sub_service_request.candidate_pppv_services
      @page_hash = params[:page_hash]
    end
    @schedule_tab = params[:schedule_tab]
  end

  def create
    @sub_service_request = SubServiceRequest.find(params[:line_item][:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    if params[:line_item][:service_id].blank?
      @sub_service_request.errors.add(:service, 'must be selected')
      @errors = @sub_service_request.errors
    elsif !@sub_service_request.create_line_item(params[:line_item])
      @errors = @sub_service_request.errors
    else
      flash[:success] = t(:dashboard)[:study_level_activities][:created]
    end
  end

  def edit
    @otf = @line_item.service.one_time_fee
    @modal_to_render = params[:modal]
    if @otf
      @header_text = t(:dashboard)[:study_level_activities][:edit]
    end
  end

  def update
    @sub_service_request = @line_item.sub_service_request
    @otf = @line_item.service.one_time_fee
    if @line_item.update_attributes(params[:line_item])
      flash[:success] = @otf ? t(:dashboard)[:study_level_activities][:updated] : t(:dashboard)[:line_items][:updated]
    else
      @errors = @line_item.errors
    end
  end

  def destroy
    @otf = @line_item.service.one_time_fee
    if @otf
      @sub_service_request = @line_item.sub_service_request
      @line_item.destroy
      flash[:alert] = t(:dashboard)[:study_level_activities][:destroyed]
    else
      @sub_service_request = @line_item.sub_service_request
      @service_request = @sub_service_request.service_request
      @selected_arm = @service_request.arms.first
      @line_items = @sub_service_request.line_items

      if @line_item.destroy
        render 'dashboard/sub_service_requests/add_line_item'
      end
    end
  end

  def update_from_cwf
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request

    updated_service_relations = true
    if params[:quantity]
      @line_item.quantity = params[:quantity]
      updated_service_relations = @line_item.valid_otf_service_relation_quantity?
    end

    if updated_service_relations && @line_item.update_attributes(params[:line_item])
      @candidate_one_time_fees = @sub_service_request.candidate_services.select(&:one_time_fee)
      render 'dashboard/sub_service_requests/add_otf_line_item'
    else
      @line_item.reload
      respond_to do |format|
        format.js { render status: 500, json: clean_errors(@line_item.errors) }
      end
    end
  end

  private

  def find_line_item
    @line_item = LineItem.find(params[:id])
  end

  def update_otf_line_item
    updated_service_relations = true
    if params[:quantity]
      @line_item.quantity = params[:quantity]
      updated_service_relations = @line_item.valid_otf_service_relation_quantity?
    end

    if updated_service_relations && @line_item.update_attributes(params[:line_item])
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @candidate_one_time_fees = @sub_service_request.candidate_services.select(&:one_time_fee)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject(&:one_time_fee)
      render 'dashboard/sub_service_requests/add_line_item'
    else
      @line_item.reload
      respond_to do |format|
        format.js { render status: 500, json: clean_errors(@line_item.errors) }
      end
    end
  end

  def update_per_patient_line_item
    #Create new line_item, and link up line_items_visit, modify CWF data, etc...
    @old_line_item = @line_item
    visit_ids = @line_items_visit.visits.pluck(:id)
    @procedures = @old_line_item.procedures.where(visit_id: visit_ids)

    ActiveRecord::Base.transaction do
      if (@line_item = LineItem.create(service_request_id: @service_request.id, service_id: @service_id, sub_service_request_id: @sub_service_request.id))
        @line_item.reload
        if @line_items_visit.update_attribute(:line_item_id, @line_item.id)
          @old_line_item.reload

          if @old_line_item.line_items_visits.empty?
            @old_line_item.destroy
          end
          return @line_item
        else
          return false
        end

      else
        return false
      end
    end
  end
end
