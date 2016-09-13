# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

desc 'Remove nexus pricing maps created on or after 08-01-2015'
task remove_nexus_pricing_maps: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_nexus_pricing_maps
    PricingMap.joins(service: :organization).where(organizations: {parent_id: 14})
  end

  def maps_to_be_deleted
    maps = get_nexus_pricing_maps
    maps_to_delete = []

    maps.each do |map|
      if (map.effective_date? && (map.effective_date >= Date.parse("2015-08-01")) && (map.service.pricing_maps.count > 1))
        maps_to_delete << map
      end
    end

    maps_to_delete
  end

  continue = prompt("Preparing to delete #{maps_to_be_deleted.count}, do you wish to continue? (Yes/No) ")

  if continue == ('Yes' || 'yes')
    puts '#'*30
    puts 'Starting deletions'
    puts '#'*30

    CSV.open("tmp/nexus_deleted_maps.csv", "w+") do |csv|
      csv << ['Core', 'Service Name', 'CPT code', 'Pricing Map Effective Date']

      maps_to_be_deleted.each do |map|
        csv << [map.service.organization.name, map.service.name, map.service.cpt_code, map.effective_date]

        puts "Pricing map with an id of #{map.id} deleted"
        map.destroy
      end
    end
  end
end