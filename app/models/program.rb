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

class Program < Organization
  audited

  belongs_to :provider, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :cores, :dependent => :destroy, :foreign_key => "parent_id"
  has_many :services, :dependent => :destroy, :foreign_key => "organization_id"

  # Surveys associated with this service
  has_many :associated_surveys, :as => :surveyable

  def populate_for_edit
    self.setup_available_statuses
  end

  def setup_available_statuses
    position = 1
    obj_names = AvailableStatus::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      available_status = available_statuses.detect{|obj| obj.status == obj_name}
      available_status = available_statuses.build(:status => obj_name, :new => true) unless available_status
      available_status.position = position
      position += 1
    end

    available_statuses.sort{|a, b| a.position <=> b.position}
  end

  def has_active_pricing_setup
    active_pricing_setup = false
    if self.pricing_setups.size > 0
      self.pricing_setups.each do |pricing_setup|
        if pricing_setup.effective_date <= Date.today
          active_pricing_setup = true
        end
      end
    end
    if !active_pricing_setup && self.provider.pricing_setups.size > 0
      self.provider.pricing_setups.each do |pricing_setup|
        if pricing_setup.effective_date <= Date.today
          active_pricing_setup = true
        end
      end
    end
    active_pricing_setup
  end
end
