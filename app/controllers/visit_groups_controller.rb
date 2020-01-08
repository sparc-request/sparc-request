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
  before_action :initialize_service_request,  unless: :in_dashboard?
  before_action :authorize_identity,          unless: :in_dashboard?
  before_action :authorize_dashboard_access,  if: :in_dashboard?
  before_action :find_visit_group,            only: [:edit, :update, :destroy]

  def new
    @arm          = Arm.find(params[:arm_id])
    @tab          = params[:tab]
    @visit_group  =
      if params[:visit_group]
        # If you mass assign position then arm_id is nil
        # making position= set position to nil as well
        vg = @arm.visit_groups.new(visit_group_params.except(:position))
        vg.assign_attributes(position: visit_group_params[:position])
        vg
      else
        @arm.visit_groups.new
      end

    setup_calendar_pages

    respond_to :js
  end

  def create
    @visit_group  = VisitGroup.new(visit_group_params.except(:position))
    @visit_group.assign_attributes(position: visit_group_params[:position])
    @tab          = params[:tab]

    setup_calendar_pages

    if @visit_group.save
      flash[:success] = t('visit_groups.created')
    else
      @errors = @visit_group.errors
    end

    @arm = @visit_group.arm ##This is after visit_group creation, so visit_count will be loaded correctly

    respond_to :js
  end

  def edit
    @visit_group.assign_attributes(visit_group_params) if params[:visit_group]

    @arm = @visit_group.arm
    @tab = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def update
    @arm = @visit_group.arm
    @tab = params[:tab]

    setup_calendar_pages

    if @visit_group.update_attributes(visit_group_params)
      flash[:success] = t('visit_groups.updated')
    else
      @errors = @visit_group.errors
    end

    respond_to :js
  end

  def destroy
    @arm = @visit_group.arm
    @tab = params[:tab]

    setup_calendar_pages
    @visit_group.destroy

    flash[:success] = t('visit_groups.deleted')

    respond_to :js
  end

  private

  def visit_group_params
    params.require(:visit_group).permit(:day, :name, :window_before, :window_after, :position, :arm_id)
  end

  def find_visit_group
    @visit_group = VisitGroup.find(params[:id])
  end
end
