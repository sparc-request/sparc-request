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

class ArmsController < ApplicationController
  respond_to :html, :js, :json

  before_action :initialize_service_request,  unless: :in_dashboard?
  before_action :authorize_identity,          unless: :in_dashboard?
  before_action :authorize_admin,             if: :in_dashboard?, except: [:index]
  before_action :authorize_overlord,          only: [:index]
  before_action :find_arm,                    only: [:edit, :update, :destroy]

  def index
    protocol = Protocol.find(params[:protocol_id])
    @arms = protocol.arms

    respond_to :json
  end

  def new
    @arm = @service_request.protocol.arms.new
    @tab = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def create
    @arm = @service_request.protocol.arms.new(arm_params)
    @tab = params[:tab]

    setup_calendar_pages

    if @arm.save
      @service_request.reload
      flash[:success] = t('arms.created')
    else
      @errors = @arm.errors
    end

    respond_to :js
  end

  def edit
    @tab = params[:tab]

    setup_calendar_pages

    respond_to :js
  end

  def update
    @tab = params[:tab]

    setup_calendar_pages

    if @arm.update_attributes(arm_params)
      flash[:success] = t('arms.updated')
    else
      @errors = @arm.errors
    end

    respond_to :js
  end

  def destroy
    @arm.destroy
    @service_request.reload

    setup_calendar_pages

    flash[:alert] = t('arms.destroyed')

    respond_to :js
  end

  private

  def arm_params
    params.require(:arm).permit(
      :name,
      :visit_count,
      :subject_count,
      :protocol_id
    )
  end

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
