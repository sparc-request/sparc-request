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

class VisitGroupsController < ApplicationController
  respond_to :json

  before_action :initialize_service_request
  before_action :authorize_identity

  def edit
    @visit_group = VisitGroup.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  # Used for x-editable update and validations
  def update
    @visit_group  = VisitGroup.find(params[:id])
    @portal       = params[:portal] == 'true'
    @review       = params[:review] == 'true'
    @admin        = params[:admin] == 'true'
    @merged       = params[:merged] == 'true'
    @consolidated = params[:consolidated] == 'true'
    @pages        = eval(params[:pages]) rescue {}
    @page         = params[:page].to_i

    unless @visit_group.update_attributes(visit_group_params)
      @errors = @visit_group.errors
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def visit_group_params
    params.require(:visit_group).permit(:day, :name, :window_before, :window_after, :position, :arm_id)
  end
end
