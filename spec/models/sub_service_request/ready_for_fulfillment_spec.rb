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
require 'rails_helper'

RSpec.describe SubServiceRequest, type: :model do
  before :each do
    @institution = Institution.new
    @institution.type = "Institution"
    @institution.abbreviation = "TECHU"
    @institution.save(validate: false)

    @provider = Provider.new
    @provider.type = "Provider"
    @provider.abbreviation = "ICTS"
    @provider.parent_id = @institution.id
    @provider.save(validate: false)

    @program = Program.new
    @program.type = "Program"
    @program.name = "BMI"
    @program.parent_id = @provider.id
    @program.save(validate: false)

    @core = Core.new
    @core.type = "Core"
    @core.name = "REDCap"
    @core.parent_id = @program.id
    @core.save(validate: false)

    @sub_service_request = SubServiceRequest.new
    @sub_service_request.organization_id = @core.id
    @sub_service_request.save(validate: false)
  end

  context 'fulfillment_contingent_on_catalog_manager is true' do
    stub_config("fulfillment_contingent_on_catalog_manager", true)

    it 'is NOT ready for fulfillment' do
      expect(@sub_service_request.ready_for_fulfillment?).to eq(false)
    end

    it 'is ready for fulfillment if already in work fulfillment' do
      @sub_service_request.in_work_fulfillment = true
      expect(@sub_service_request.ready_for_fulfillment?).to eq(true)
    end

    it 'is ready for fulfillment if the service is directly under an organization with the tag "clinical work fulfillment"' do
      @core.tag_list << "clinical work fulfillment"
      @core.save(validate: false)
      expect(@sub_service_request.ready_for_fulfillment?).to eq(true)
    end

    it 'is NOT ready for fulfillment if the service has a grandparent organization with the tag "clinical work fulfillment"' do
      @program.tag_list << "clinical work fulfillment"
      @program.save(validate: false)
      expect(@sub_service_request.ready_for_fulfillment?).to eq(false)
    end
  end

  context 'fulfillment_contingent_on_catalog_manager is false' do
    stub_config("fulfillment_contingent_on_catalog_manager", false)

    it 'is ready for fulfillment' do
      expect(@sub_service_request.ready_for_fulfillment?).to eq(true)
    end

    it 'is ready for fulfillment if already in work fulfillment' do
      @sub_service_request.in_work_fulfillment = true
      expect(@sub_service_request.ready_for_fulfillment?).to eq(true)
    end

    it 'is ready for fulfillment if the service is directly under an organization with the tag "clinical work fulfillment"' do
      @core.tag_list << "clinical work fulfillment"
      @core.save(validate: false)
      expect(@sub_service_request.ready_for_fulfillment?).to eq(true)
    end
  end
end
