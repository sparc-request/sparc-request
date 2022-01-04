# Copyright © 2011-2020 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.describe FeeAgreement::NonClinicalServiceRow do
  let(:protocol) { create(:protocol_federally_funded) }
  let(:service) { create(:service_with_pricing_map, :one_time_fee) }
  let(:line_item) { create(:line_item_with_service, :one_time_fee, service: service, protocol: protocol) }

  context('initialization from a line item') do
    let(:row) { FeeAgreement::NonClinicalServiceRow.new(line_item) }

    it('sets the program name') do
      expect(row.program_name).to eq(service.organization.name)
    end

    it('sets the service name') do
      expect(row.service_name).to eq(service.name)
    end

    it('sets the service cost') do
      expect(row.service_cost).to eq(line_item.applicable_rate)
    end

    it('sets the quantity') do
      expect(row.quantity).to eq(line_item.quantity)
    end

    it('computes the total dollars') do
      expected = Service.cents_to_dollars(line_item.applicable_rate * line_item.quantity)
      expect(row.total).to eq(expected)
    end
  end
end
