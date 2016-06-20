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

class CatalogManager::ProgramsController < CatalogManager::AppController
  respond_to :js, :html, :json
  layout false

  def create
    @provider = Provider.find(params[:provider_id])
    @program = Program.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @provider.id})
    @program.build_subsidy_map()
    @program.save
    
    respond_with [:catalog_manager, @program]
  end

  def show
    @organization = Organization.find params[:id]
    @program = Program.find params[:id]
    @program.setup_available_statuses
  end
  
  def update
    @program = Program.find(params[:id])

    unless params[:program][:tag_list]
      params[:program][:tag_list] = ""
    end

    params[:program].delete(:id)

    if @program.update_attributes(params[:program])
      flash[:notice] = "#{@program.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@program.name}."
    end
    
    params[:pricing_setups].each do |ps|
      if ps[1]['id'].blank?
        ps[1].delete(:id)
        ps[1].delete(:newly_created)
        @program.pricing_setups.build(ps[1])
      else
        ps_id = ps[1]['id']
        ps[1].delete(:id)
        @program.pricing_setups.find(ps_id).update_attributes(ps[1])        
      end
      @program.save
    end if params[:pricing_setups]
  
    @program.setup_available_statuses      
    @entity = @program
    respond_with @program, :location => catalog_manager_program_path(@program)
  end

end
