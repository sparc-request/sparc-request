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

class VisitGroupsController < ApplicationController
  respond_to :json

  before_filter :initialize_service_request
  before_filter :authorize_identity

  # Used for x-editable update and validations
  def update
    @visit_group = VisitGroup.find(params[:id])

    if @visit_group.update_attributes(visit_group_params)
      render nothing: true
    else
      # If we update the visit group day, then @visit_group.day is already updated, therefore
      # any errors for day are not deleted.
      # If we update a different attribute, then day will be nil and the errors for day
      # will be deleted.
      if @visit_group.day.nil?
        @visit_group.errors.delete(:day)
      end

      # If there are legitimate errors, render them
      # Else, it means day validation caused the update_attributes to fail even though we didn't
      # change it, so we ignore validation and update the attribute correctly.
      if @visit_group.errors.any?
        render json: @visit_group.errors, status: :unprocessable_entity
      else
        @visit_group.attributes = visit_group_params
        @visit_group.save(validate: false)
        render nothing: true
      end
    end
  end

  private

  def visit_group_params
    params.require(:visit_group).permit(:day, :name, :window_before, :window_after, :position, :arm_id)
  end
end
