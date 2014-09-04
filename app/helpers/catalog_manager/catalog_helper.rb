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

module CatalogManager::CatalogHelper
  def node object, can_access=true, id=nil
    link_to display_name(object), '#', :id => id, :cid => object.id, :object_type => object.class.to_s.downcase, :class => can_access ? "#{object.class.to_s.downcase}" : "#{object.class.to_s.downcase} disabled_node"
  end
  
  def disable_pricing_setup(pricing_setup, can_edit_historical_data)
    begin
      if can_edit_historical_data == false
        (pricing_setup.effective_date <= Date.today) || (pricing_setup.display_date <= Date.today) ? true : false
      else
        false
      end
    rescue
      false
    end
  end

  def disable_pricing_map(pricing_map, can_edit_historical_data)
    if can_edit_historical_data == false
      (pricing_map.effective_date <= Date.today) || (pricing_map.display_date <= Date.today) ? true : false
    else
      false
    end
  end
end
def display_name object
  object.respond_to?(:cpt_code) ? object.display_service_name : object.name
end
