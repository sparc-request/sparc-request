# Copyright © 2011 MUSC Foundation for Research Development
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

class Portal::LineItemsController < Portal::BaseController
  respond_to :json, :js, :html
  before_action :find_line_item, only: [:edit, :update, :destroy, :details]

  def index
    respond_to do |format|
      format.json {
        @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
        @line_items = @sub_service_request.one_time_fee_line_items

        render
      }
    end
  end

  def new
    # called to render modal to create line items
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    if params[:one_time_fee]
      @services = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
    else
      @services = @sub_service_request.candidate_services.select {|x| !x.one_time_fee}
      @page_hash = params[:page_hash]
    end
    @schedule_tab = params[:schedule_tab]
  end

  def create
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service_request = @sub_service_request.service_request
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}

    if @sub_service_request.create_line_item(
        service_id: params[:add_service_id],
        sub_service_request_id: params[:sub_service_request_id])
    else
      @errors = @sub_service_request.errors
    end
  end

#   def edit
#     @protocol = @line_item.protocol
#     @otf = @line_item.one_time_fee
#   end

#   def update
#     @otf = @line_item.one_time_fee
#     persist_original_attributes_to_track_changes if @otf
#     if @line_item.update_attributes(line_item_params)
#       @line_item.update_columns(quantity_type: @line_item.service.current_effective_pricing_map.quantity_type)
#       if @otf
#         detect_changes_and_create_notes # study level charges needs notes for changes
#       else
#         update_line_item_procedures_service # study schedule line item service change
#       end
#       flash[:success] = t(:line_item)[:flash_messages][:updated]
#     else
#       @errors = @line_item.errors
#     end
#   end

  def destroy
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @selected_arm = @service_request.arms.first
    @study_tracker = params[:study_tracker] == "true"
    @line_items = @sub_service_request.line_items

    if @line_item.destroy
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:fix_pi_contribution, percent)
      @service_request = @sub_service_request.service_request
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.one_time_fee}

      render 'portal/sub_service_requests/add_line_item'
    end
  end

  def update_from_fulfillment
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @selected_arm = @service_request.arms.first
    @subsidy = @sub_service_request.subsidy
    @percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @study_tracker = params[:study_tracker] == "true"
    @line_items_visit = LineItemsVisit.find(params[:line_items_visit_id]) if params[:line_items_visit_id]
    @service_id = params[:service_id]

    if @line_item.service.one_time_fee
      update_otf_line_item()
    else
      if params[:displayed_cost] # we only want to update the displayed cost
        @line_item.displayed_cost = params[:displayed_cost] || ''
        @line_item.save
        reload_request
      elsif update_per_patient_line_item()
        reload_request
      else
        @line_item.reload
        respond_to do |format|
          format.js { render :status => 500, :json => clean_errors(@line_item.errors) } 
        end
      end
    end
  end

  def update_from_cwf
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request

    # @study_tracker = params[:study_tracker] == "true"
    @study_tracker = true
    # @study_tracker must be true here, as it is coming from cwf.
    # problem occurred because there is no :study_tracker param at this point.

    updated_service_relations = true
    if params[:quantity]
      @line_item.quantity = params[:quantity]
      updated_service_relations = @line_item.valid_otf_service_relation_quantity?
    end
  
    if updated_service_relations && @line_item.update_attributes(params[:line_item])
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
      render 'portal/sub_service_requests/add_otf_line_item'
    else
      @line_item.reload
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@line_item.errors) }
      end
    end
  end

  private

  def find_line_item
    @line_item = LineItem.find params[:id]
  end

  def reload_request
     # Have to reload the service request to get the correct direct cost total for the subsidy
    @subsidy.try(:sub_service_request).try(:reload)
    @subsidy.try(:fix_pi_contribution, @percent)
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.one_time_fee}
    render 'portal/sub_service_requests/add_line_item'
  end

  def update_otf_line_item
    updated_service_relations = true
    if params[:quantity]
      @line_item.quantity = params[:quantity]
      updated_service_relations = @line_item.valid_otf_service_relation_quantity?
    end

    if updated_service_relations && @line_item.update_attributes(params[:line_item])
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, @percent)
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.one_time_fee}
      render 'portal/sub_service_requests/add_line_item'
    else
      @line_item.reload
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@line_item.errors) }
      end
    end
  end

  def update_per_patient_line_item
    #Create new line_item, and link up line_items_visit, modify CWF data, etc...
    @old_line_item = @line_item
    visit_ids = @line_items_visit.visits.map(&:id)
    @procedures = @old_line_item.procedures.find_all_by_visit_id(visit_ids)

    ActiveRecord::Base.transaction do
      if @line_item = LineItem.create(service_request_id: @service_request.id, service_id: @service_id, sub_service_request_id: @sub_service_request.id)

        @line_item.reload
        if @line_items_visit.update_attribute(:line_item_id, @line_item.id)
          @old_line_item.reload

          if @sub_service_request.in_work_fulfillment
            #Modify Procedures in CWF
            @procedures.each do |procedure|
              if procedure.completed?
                procedure.update_attributes(service_id: @old_line_item.service.id, line_item_id: nil)
              else
                procedure.update_attribute(:line_item_id, @line_item.id)
              end
            end
          end

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


# class LineItemsController < ApplicationController

#   before_action :find_line_item, only: [:edit, :update]

#   def index
#     respond_to do |format|
#       format.json {
#         @protocol = Protocol.find(params[:protocol_id])
#         @line_items = @protocol.one_time_fee_line_items

#         render
#       }
#     end
#   end

#   def new
#     @protocol = Protocol.find(params[:protocol_id])
#     @line_item = LineItem.new(protocol: @protocol)
#   end

#   def create
#     @line_item = LineItem.new(line_item_params)
#     if @line_item.valid?
#       @line_item.quantity_type = @line_item.service.current_effective_pricing_map.quantity_type
#       @line_item.save
#       flash[:success] = t(:line_item)[:flash_messages][:created]
#     else
#       @errors = @line_item.errors
#     end
#   end

#   def edit
#     @protocol = @line_item.protocol
#     @otf = @line_item.one_time_fee
#   end

#   def update
#     @otf = @line_item.one_time_fee
#     persist_original_attributes_to_track_changes if @otf
#     if @line_item.update_attributes(line_item_params)
#       @line_item.update_columns(quantity_type: @line_item.service.current_effective_pricing_map.quantity_type)
#       if @otf
#         detect_changes_and_create_notes # study level charges needs notes for changes
#       else
#         update_line_item_procedures_service # study schedule line item service change
#       end
#       flash[:success] = t(:line_item)[:flash_messages][:updated]
#     else
#       @errors = @line_item.errors
#     end
#   end

#   def destroy
#     @line_item = LineItem.find(params[:id])
#     if @line_item.fulfillments.empty?
#       @line_item.destroy
#       flash[:success] = t(:line_item)[:flash_messages][:deleted]
#     else
#       flash[:alert] = t(:line_item)[:flash_messages][:not_deleted]
#     end
#   end

#   private

#   def persist_original_attributes_to_track_changes
#     @original_attributes = @line_item.attributes
#   end

#   def detect_changes_and_create_notes
#     tracked_fields = ["quantity_requested", "service_id", "started_at"]
#     tracked_fields.each do |field|
#       current_field = @original_attributes[field]
#       new_field = line_item_params[field]
#       unless new_field.blank?
#         unless current_field.blank?
#           current_field = (field == "started_at" ? current_field.to_date.to_s : current_field.to_s)
#           new_field = (field == "started_at" ? Time.strptime(new_field, "%m-%d-%Y").to_date.to_s : new_field)
#         end
#         if current_field != new_field
#           comment = t(:line_item)[:log_notes][field.to_sym] + (field == "service_id" ? Service.find(new_field).name : new_field.to_s)
#           @line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
#         end
#       end
#     end
#   end

#   def update_line_item_procedures_service
#     # Need to change any procedures that haven't been completed to the new service
#     service = @line_item.service
#     service_name = service.name
#     @line_item.visits.each do |v|
#       v.procedures.select{ |p| not(p.appt_started? or p.complete?) }.each do |p|
#         p.update_attributes(service_id: service.id, service_name: service_name)
#       end
#     end
#   end

#   def line_item_params
#     params.require(:line_item).permit(:protocol_id, :quantity_requested, :service_id, :started_at, :account_number, :contact_name)
#   end



# end

