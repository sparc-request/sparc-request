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

class Dashboard::FulfillmentsController < Dashboard::BaseController

  before_action :find_fulfillment, only: [:edit, :update, :destroy]

  def index
    @line_item = LineItem.find(params[:line_item_id])
    respond_to do |format|
      format.js { render }
      format.json {
        @fulfillments = @line_item.fulfillments

        render
      }
    end
  end

  def new
    @fulfillment = Fulfillment.new(line_item_id: params[:line_item_id])
    @header_text = 'Create New Fulfillment'
  end

  def create
    @fulfillment = Fulfillment.new(params[:fulfillment])
    if @fulfillment.valid?
      @fulfillment.save
      flash[:success] = "Fulfillment Created!"
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
    @header_text = "Edit Fulfillment"
  end

  def update
    if @fulfillment.update_attributes(params[:fulfillment])
      flash[:success] = "Fulfillment Updated!"
    else
      @errors = @fulfillment.errors
    end
  end

  def destroy
    @sub_service_request = @fulfillment.line_item.sub_service_request
    if @fulfillment.delete
      flash[:alert] = "Fulfillment Destroyed!"
    end
  end

  def update_from_fulfillment
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.update_attributes(params[:fulfillment])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@fulfillment.errors) } 
      end
    end
  end

  private

  def find_fulfillment
    @fulfillment = Fulfillment.find params[:id]
  end
end
