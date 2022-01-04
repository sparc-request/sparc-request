# Copyright © 2011-2020 MUSC Foundation for Research Development
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

class Admin::ApplicationsController < Doorkeeper::ApplicationsController

  before_action :set_application, only: [:edit, :update, :destroy, :regenerate_secret]

  def index
    respond_to do |format|
      format.html
      format.js
      format.json {
        @applications = Doorkeeper.config.application_model.ordered_by(:created_at)
      }
    end
  end

  def create
    respond_to :js
    @application = Doorkeeper.config.application_model.new(application_params)

    if @application.save
      render json: { id: @application.id }, status: :ok
    else
      @errors = @application.errors

      render status: :unprocessable_entity
    end
  end

  def edit
    respond_to :html
  end

  def update
    respond_to :js

    if @application.update_attributes(application_params)
      flash.now[:success] = t('admin.applications.updated')
    else
      @errors = @application.errors
    end
  end

  def destroy
    respond_to :js

    @application.destroy
    flash.now[:alert] = t('admin.applications.deleted')
  end

  def regenerate_secret
    respond_to :js

    @application.renew_secret
    @application.save(validate: false)
    flash.now[:success] = t('admin.applications.updated')
    render action: :update
  end
end
