# Copyright © 2011-2016 MUSC Foundation for Research Development
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

class PricingSetup < ActiveRecord::Base
  audited

  belongs_to :organization

  attr_accessible :organization_id
  attr_accessible :display_date
  attr_accessible :effective_date
  attr_accessible :charge_master
  attr_accessible :federal #o
  attr_accessible :corporate #o
  attr_accessible :other #o
  attr_accessible :member #o
  attr_accessible :college_rate_type
  attr_accessible :federal_rate_type
  attr_accessible :foundation_rate_type
  attr_accessible :industry_rate_type
  attr_accessible :investigator_rate_type
  attr_accessible :internal_rate_type
  attr_accessible :unfunded_rate_type
  
  after_create :create_pricing_maps

  validates :display_date, :effective_date, :corporate, :other, :member, :college_rate_type,
            :foundation_rate_type, :industry_rate_type, :investigator_rate_type,
            :internal_rate_type, presence: true

  def rate_type(funding_source)
    case funding_source
    when 'college'       then self.college_rate_type
    when 'federal'       then self.federal_rate_type
    when 'foundation'    then self.foundation_rate_type
    when 'industry'      then self.industry_rate_type
    when 'investigator'  then self.investigator_rate_type
    when 'internal'      then self.internal_rate_type
    when 'unfunded'      then self.unfunded_rate_type
    else raise ArgumentError, "Could not find rate type for funding source #{funding_source}"
    end
  end

  def applied_percentage(rate_type)
    applied_percentage = case rate_type
    when 'federal' then self.federal
    when 'corporate' then self.corporate
    when 'other' then self.other
    when 'member' then self.member
    when 'full' then 100
    else raise ArgumentError, "Could not find applied percentage for rate type #{rate_type}"
    end

    applied_percentage = applied_percentage / 100.0 rescue nil

    return applied_percentage || 1.0
  end

  def create_pricing_maps
    # If there is no organization, then there are no pricing maps
    return if self.organization.nil?

    self.organization.all_child_services.each do |service|
      current_map = nil
      begin
        effective_pricing_map = service.effective_pricing_map_for_date(self.effective_date).attributes

        ## Deleting the attributes to prevent mass-assignment errors.
        effective_pricing_map.delete('id')
        effective_pricing_map.delete('created_at')
        effective_pricing_map.delete('updated_at')
        effective_pricing_map.delete('deleted_at')

        current_map = PricingMap.new(effective_pricing_map)
      rescue
        current_map = service.pricing_maps.build
        current_map.full_rate = 0
        current_map.unit_factor = 1
        current_map.unit_minimum = 1
        current_map.unit_type = "Each"
      end

      current_map.effective_date = self.effective_date.to_date
      current_map.display_date = self.display_date.to_date
      current_map.save
    end
  end
end

