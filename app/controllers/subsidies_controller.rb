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

class SubsidiesController < ApplicationController
  respond_to :json, :js, :html

  def new
    @subsidy = PendingSubsidy.new(sub_service_request_id: params[:ssrid])
    @header_text = t(:subsidies)[:new]
    @admin = false
    @path = subsidies_path
    @subsidy.percent_subsidy = (@subsidy.default_percentage / 100.0)
    @action = 'new'
  end

  def create
    @subsidy = PendingSubsidy.new(subsidy_params)
    if @subsidy.valid?
      @subsidy.save
      @sub_service_request = @subsidy.sub_service_request
      @admin = false
      flash[:success] = t(:subsidies)[:created]
    else
      @errors = @subsidy.errors
    end
  end

  def edit
    @subsidy = PendingSubsidy.find(params[:id])
    @header_text = t(:subsidies)[:edit]
    @admin = false
    @path = subsidy_path(@subsidy)
    @action = 'edit'
  end

  def update
    @subsidy = PendingSubsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.update_attributes(subsidy_params)
      @admin = false
      flash[:success] = t(:subsidies)[:updated]
    else
      @errors = @subsidy.errors
      @subsidy.reload
    end
  end

  def destroy
    @subsidy = Subsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.destroy
      @admin = false
      flash[:alert] = t(:subsidies)[:destroyed]
    end
  end

  private

  def subsidy_params
    @subsidy_params ||= begin
      temp = params.require(:pending_subsidy).permit(:sub_service_request_id,
        :overridden,
        :status,
        :percent_subsidy)
      if temp[:percent_subsidy].present?
        temp[:percent_subsidy] = temp[:percent_subsidy].gsub(/[^\d^\.]/, '').to_f / 100
      end
      temp
    end
  end

  def find_subsidy
    @subsidy = PendingSubsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
  end
end
