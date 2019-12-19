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

class Dashboard::ClinicalLineItemsController < Dashboard::BaseController
  before_action :authorize_admin

  def new
    @line_item  = @service_request.line_items.new(sub_service_request_id: @sub_service_request.id)
    @tab        = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def create
    line_item = @sub_service_request.line_items.new(service_request: @service_request, service_id: line_item_params[:service_id])

    if line_item.valid?
      @service  = Service.find(line_item_params[:service_id])
      lis       = @service_request.create_line_items_for_service(service: @service, optional: true, recursive_call: false )
      @tab      = params[:tab]

      lis.each{ |li| li.update_attribute(:sub_service_request, @sub_service_request) }

      unless @service_request.arms.any?
        @service_request.protocol.arms.create(name: 'Screening Phase', visit_count: 1, new_with_draft: true)
      end

      flash[:success] = t('line_items.created')
    else
      @errors = line_item.errors
    end

    setup_calendar_pages

    respond_to :js
  end

  def edit
    @line_item  = @service_request.line_items.new(sub_service_request_id: @sub_service_request.id)
    @tab        = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def destroy
    if line_item_params[:id].present?
      @line_item  = LineItem.find(line_item_params[:id])
      @tab        = params[:tab]

      setup_calendar_pages
      @line_item.destroy

      flash[:alert] = t('line_items.deleted')
    else
      line_item = @service_request.line_items.new
      line_item.valid?
      @errors = line_item.errors.messages[:service_id]
    end

    respond_to :js
  end

  private

  def line_item_params
    params.require(:line_item).permit(:service_id, :id)
  end
end
