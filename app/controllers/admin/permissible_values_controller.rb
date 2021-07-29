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


class Admin::PermissibleValuesController < Admin::BaseController

    def index
      @permissible_values = PermissibleValue.reorder('category , is_available DESC, sort_order')
      respond_to :json, :html
    end

    def show
      @permissible_value = PermissibleValue.find(params[:id])
      respond_to :js
    end

    def new
      @permissible_value = PermissibleValue.new(is_available: false)
      respond_to :js
    end

    def create
      @permissible_value = PermissibleValue.new(permissible_value_params)
      
      if @permissible_value.save
        flash.now[:success] = t('admin.permissible_values.created')
      else
        @errors = @permissible_value.errors
      end

      respond_to :js
    end

    def edit
      respond_to :js      
      @permissible_value = PermissibleValue.find(params[:id])
    end

    def update
      @permissible_value = PermissibleValue.find(params[:id])

      if @permissible_value.update_attributes(permissible_value_params)
        flash.now[:success] = t('admin.permissible_values.updated')
      else
        @errors = @permissible_value.errors
      end

      respond_to :js
    end


    protected

    def permissible_value_params
      params.require(:permissible_value).permit(
        :key,
        :value,
        :sort_order,
        :category,
        :is_available,
        :default
      )
    end
  
  end
