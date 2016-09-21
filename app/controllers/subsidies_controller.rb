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

class SubsidiesController < ApplicationController
  before_filter :find_subsidy, only: [:update, :destroy]

  def create
    @sub_service_request = SubServiceRequest.find params[:subsidy][:sub_service_request_id]
    @subsidy = PendingSubsidy.new(sub_service_request_id: @sub_service_request.id)
    @subsidy.percent_subsidy = @subsidy.default_percentage
    @subsidy.save(validate: false)
  end

  def update
    format_percent_subsidy_param
    unless @subsidy.update_attributes(params[:subsidy].except(:pi_contribution))
      @errors = @subsidy.errors.full_messages
    end
  end

  def destroy
    @subsidy.destroy
  end

  private

  def find_subsidy
    @subsidy = PendingSubsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
  end

  def format_percent_subsidy_param
    if !params[:subsidy].nil? && params[:subsidy][:percent_subsidy].present?
      params[:subsidy][:percent_subsidy] = (params[:subsidy][:percent_subsidy].gsub(/[^\d^\.]/, '').to_f)
    end
  end
end
