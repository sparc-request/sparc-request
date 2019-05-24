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

# this controller exists in order to separate the mass creation of line items
# from single line item creation and deletion which will happen on the study schedule
class Dashboard::MultipleLineItemsController < Dashboard::BaseController

  respond_to :js

  def new_line_items
    # called to render modal to mass create line items
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @protocol = Protocol.find params[:protocol_id]
    # TODO change back to not otf services
    @services = @sub_service_request.candidate_services.select {|x| !x.one_time_fee}
    # @services = @protocol.organization.inclusive_child_services(:per_participant)
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
  end

  def create_line_items
    # handles submission of the add line items form
    @service_request = ServiceRequest.find(params[:service_request_id])
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @service = Service.find(params[:add_service_id])
    existing_service_ids = @service_request.line_items.pluck(:service_id)

    # # we don't have arms and we are adding a new per patient per visit service
    if @service_request.arms.empty? && !@service.one_time_fee
      @service_request.protocol.arms.create(name: 'Screening Phase', visit_count: 1, subject_count: 1)
    end

    ActiveRecord::Base.transaction do
      if (@new_line_items = @service_request.create_line_items_for_service(
          service: @service,
          optional: true,
          existing_service_ids: existing_service_ids,
          allow_duplicates: true))

        @new_line_items.each do |line_item|
          line_item.update_attribute(:sub_service_request_id, @sub_service_request.id)
        end

        flash.now[:success] = t(:dashboard)[:multiple_line_items][:created]
      else
        @errors = @service_request.errors
      end
    end
  end

  def edit_line_items
    @sub_service_request  = SubServiceRequest.find(params[:sub_service_request_id])
  end

  def destroy_line_items
    @line_item            = LineItem.find(params[:line_item_id])
    @sub_service_request  = @line_item.sub_service_request
    @service_request      = @sub_service_request.service_request

    @line_item.destroy

    flash.now[:alert] = t(:dashboard)[:multiple_line_items][:destroyed]
  end
end
