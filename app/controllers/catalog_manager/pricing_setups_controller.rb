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

class CatalogManager::PricingSetupsController < CatalogManager::AppController

  def new
    @pricing_setup = PricingSetup.new()
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @pricing_setup = PricingSetup.new(pricing_setup_params)

    if @pricing_setup.save
      flash[:success] = "Pricing Setup created successfully."
      @organization = @pricing_setup.organization
    else
      @errors = @pricing_setup.errors
    end
  end

  def edit
    @pricing_setup = PricingSetup.find(params[:id])
    @organization = @pricing_setup.organization
  end

  def update
    @pricing_setup = PricingSetup.find(params[:id])

    if @pricing_setup.update_attributes(pricing_setup_params)
      flash[:success] = "Pricing Setup updated successfully."
      @organization = @pricing_setup.organization
    else
      @errors = @pricing_setup.errors
    end
  end


  private

  def pricing_setup_params
    params.require(:pricing_setup).permit(
      :display_date,
      :effective_date,
      :charge_master,
      :federal,
      :corporate,
      :other,
      :member,
      :college_rate_type,
      :federal_rate_type,
      :industry_rate_type,
      :investigator_rate_type,
      :internal_rate_type,
      :foundation_rate_type,
      :unfunded_rate_type,
      :organization_id
    )
  end
end
