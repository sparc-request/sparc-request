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

class CatalogManager::CoresController < CatalogManager::AppController
  layout false
  respond_to :js, :html
  
  def create
    @program = Program.find(params[:program_id])
    @core = Core.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @program.id})
    @core.build_subsidy_map()
    @core.save
    
    respond_with [:catalog_manager, @core]
  end
  
  def show
    @core = Core.find(params[:id])
    @core.setup_available_statuses
  end
  
  def update
    @core = Core.find(params[:id])

    unless params[:core][:tag_list]
      params[:core][:tag_list] = ""
    end

    params[:core].delete(:id)
    if @core.update_attributes(params[:core])
      flash[:notice] = "#{@core.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@core.name}."
    end
    
    @core.setup_available_statuses
    @entity = @core
    respond_with @core, :location => catalog_manager_core_path(@core)          
  end
  
end
