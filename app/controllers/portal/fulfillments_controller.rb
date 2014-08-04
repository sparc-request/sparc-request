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

class Portal::FulfillmentsController < Portal::BaseController
  respond_to :js, :json, :html

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

  def create
    if @fulfillment = Fulfillment.create(params[:fulfillment])
      @sub_service_request = @fulfillment.line_item.sub_service_request
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      @active = @fulfillment.line_item.id
      render 'create'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@fulfillment.errors) } 
      end
    end
  end

  def destroy
    @fulfillment = Fulfillment.find(params[:id])
    @sub_service_request = @fulfillment.line_item.sub_service_request
    if @fulfillment.delete
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      render 'create'
    end
  end
end
