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

class CatalogManager::SubsidyMapsController < CatalogManager::AppController
  def edit
    @subsidy_map = SubsidyMap.find(params[:id])
  end

  def update
    @subsidy_map = SubsidyMap.find(params[:id])

    if @subsidy_map.update_attributes(subsidy_map_params.except(:excluded_funding_sources))
      ##Update the excluded funding sources
      update_excluded_funding_sources(subsidy_map_params[:excluded_funding_sources].delete_if{|source| source == ""}, @subsidy_map)

      flash[:success] = "Subsidy Map updated successfully."
    else
      @errors = @subsidy_map.errors
    end
  end

  private

  def update_excluded_funding_sources(new_funding_source_list, subsidy_map)
    ##Destroy any that are no longer selected
    subsidy_map.excluded_funding_sources.each do |excluded_funding_source|
      excluded_funding_source.destroy unless new_funding_source_list.include?(excluded_funding_source.funding_source)
    end

    ##Create any that are newly selected
    new_funding_source_list.each do |funding_source|
      subsidy_map.excluded_funding_sources.create(funding_source: funding_source) unless subsidy_map.excluded_funding_sources.map(&:funding_source).include?(funding_source)
    end
  end

  def subsidy_map_params
    params.require(:subsidy_map).permit(
      :max_percentage,
      :default_percentage,
      :max_dollar_cap,
      :instructions,
      excluded_funding_sources: [],
    )
  end

end
