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

class CatalogManager::PricingMapsController < CatalogManager::AppController

  def new
    @pricing_map = PricingMap.new()
    @service = Service.find(params[:service_id])
  end

  def create
    @pricing_map = PricingMap.new(pricing_map_params)

    if @pricing_map.save
      flash[:success] = "Pricing Map created successfully."
      @service = @pricing_map.service
      @programs = @service.provider.programs
      @cores    = @service.program.cores
    else
      @errors = @pricing_map.errors
    end
  end

  def edit
    @pricing_map = PricingMap.find(params[:id])
    @service = @pricing_map.service
  end

  def update
    @pricing_map = PricingMap.find(params[:id])

    if @pricing_map.update_attributes(pricing_map_params)
      flash[:success] = "Pricing Map updated successfully."
      @service = @pricing_map.service
    else
      @errors = @pricing_map.errors
    end
  end

  def refresh_rates
    if params[:id]
      @pricing_map = PricingMap.find(params[:id])
      @pricing_map_disabled = @pricing_map.disabled?(@user)
    else
      @pricing_map = PricingMap.new(service_id: pricing_map_params[:service_id])
      @pricing_map_disabled = false
    end
    @rate_map = @pricing_map.service.get_rate_maps(pricing_map_params[:display_date].to_date.strftime("%F"), pricing_map_params[:full_rate]) rescue nil
  end

  private

  def pricing_map_params
    temp = params.require(:pricing_map).permit(
      :display_date,
      :effective_date,
      :full_rate,
      :federal_rate,
      :corporate_rate,
      :other_rate,
      :member_rate,
      :unit_type,
      :unit_factor,
      :unit_minimum,
      :units_per_qty_max,
      :otf_unit_type,
      :quantity_minimum,
      :quantity_type,
      :exclude_from_indirect_cost,
      :service_id
    )

    temp[:full_rate] = Service.dollars_to_cents(temp[:full_rate]) unless temp[:full_rate].blank?
    temp[:federal_rate] = Service.dollars_to_cents(temp[:federal_rate]) unless temp[:federal_rate].blank?
    temp[:corporate_rate] = Service.dollars_to_cents(temp[:corporate_rate]) unless temp[:corporate_rate].blank?
    temp[:other_rate] = Service.dollars_to_cents(temp[:other_rate]) unless temp[:other_rate].blank?
    temp[:member_rate] = Service.dollars_to_cents(temp[:member_rate]) unless temp[:member_rate].blank?

    temp
  end
end
