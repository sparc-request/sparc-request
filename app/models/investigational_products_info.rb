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

class InvestigationalProductsInfo < ActiveRecord::Base
  EXEMPTION_TYPES = ["ide", "hde", "hud", ""].freeze
  self.table_name = 'investigational_products_info'

  audited

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :ind_number
  attr_accessible :inv_device_number
  attr_accessible :exemption_type
  attr_accessible :ind_on_hold

  validates :exemption_type, inclusion: { in: EXEMPTION_TYPES, message: "not among #{EXEMPTION_TYPES.map(&:upcase).join(', ')}" }
  validate :inv_device_number_present_when_exemption_type_present

  private

  def inv_device_number_present_when_exemption_type_present
    if exemption_type.present? && inv_device_number.blank?
      errors.add(:inv_device_number, "(#{exemption_type.upcase}#) can't be blank")
    end
  end
end
