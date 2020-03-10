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

module CatalogsHelper
  def catalog_institutions(shard, external)
    Institution.all.includes(:services, org_children: { org_children: [:services, org_children: [:services, :org_children]]}).select do |inst|
      inst.is_available != false && inst.all_child_services(true, true).any? do |s|
        s.is_available != false && (!external || s.share_externally?)
      end
    end
  end

  def catalog_providers(institution, shard, external)
    institution.org_children.select do |prov|
      prov.is_available != false && prov.all_child_services(true, true).any? do |s|
        s.is_available != false && (!external || s.share_externally?)
      end
    end
  end

  def catalog_programs(provider, shard, external)
    provider.org_children.select do |prog|
      prog.is_available != false && prog.all_child_services(true, true).any? do |s|
        s.is_available != false && (!external || s.share_externally?)
      end
    end
  end

  def catalog_cores(program, shard, external)
    program.cores.eager_load(services: [:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: :pricing_setups]]]).select do |core|
      if @core
        @core == core
      else
        core.is_available != false && core.services.any? do |s|
          s.is_available != false && s.current_pricing_map && (!external || s.share_externally?)
        end
      end
    end
  end

  def catalog_services(organization, shard, external)
    organization.services.eager_load(:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]).select do |s|
      if @service
        @service == s
      else
        s.is_available != false && s.current_pricing_map && (!external || s.share_externally?)
      end
    end
  end
end
