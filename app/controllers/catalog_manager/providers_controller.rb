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

class CatalogManager::ProvidersController < CatalogManager::AppController
  respond_to :js, :html, :json  
  layout false

  def create
    @institution = Institution.find(params[:institution_id])
    @provider = Provider.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @institution.id})
    @provider.build_subsidy_map()
    @provider.save
    
    respond_with [:catalog_manger, @provider]
  end

  def show
    @provider = Provider.find(params[:id])
    @provider.setup_available_statuses
  end

  def update
    @provider = Provider.find(params[:id])

    unless params[:provider][:tag_list]
      params[:provider][:tag_list] = ""
    end

    params[:provider].delete(:id)    
    if @provider.update_attributes(params[:provider])
      flash[:notice] = "#{@provider.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@provider.name}."
    end
    
    params[:pricing_setups].each do |ps|
      if ps[1]['id'] == 'blank'
        ps[1].delete(:id)
        ps[1].delete(:newly_created)
        @provider.pricing_setups.build(ps[1])
      else
        # @provider.pricing_setups.find(ps[1]['id']).update_attributes(ps[1])
        ps_id = ps[1]['id']
        ps[1].delete(:id)
        @provider.pricing_setups.find(ps_id).update_attributes(ps[1])        
      end
      @provider.save
    end if params[:pricing_setups]

    @provider.setup_available_statuses
    @entity = @provider
    respond_with @provider, :location => catalog_manager_provider_path(@provider)
  end

end
