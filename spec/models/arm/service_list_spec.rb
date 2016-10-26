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

require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#service_list' do
    before(:all) do
      @sr   = create(:service_request_without_validations)
      @arm  = create(:arm, service_request: @sr)

      # org1(not ssrs) <- org2(not ssrs)* <- s1(not otf)
      @org1 = create(:organization, process_ssrs: false, parent: nil)
      @org2 = create(:organization, process_ssrs: false, parent: @org1)
      @s1   = create(:service, organization: @org2, one_time_fee: false)
      @li1  = create(:line_item, service: @s1, service_request: @sr)
      @liv1 = create(:line_items_visit, arm: @arm, line_item: @li1)

      # org2 <- s2(otf)
      @s2   = create(:service, organization: @org2, one_time_fee: true)
      @li2  = create(:line_item, service: @s2, service_request: @sr)
      @liv2 = create(:line_items_visit, arm: @arm, line_item: @li2)

      # org3(ssrs)* <- org4(ssrs) <- s3(not otf)
      @org3 = create(:organization, process_ssrs: true, parent: nil)
      @org4 = create(:organization, process_ssrs: true, parent: @org3)
      @s3   = create(:service, organization: @org3, one_time_fee: false)
      @li3  = create(:line_item, service: @s3, service_request: @sr)
      @liv3 = create(:line_items_visit, arm: @arm, line_item: @li3)

      # org3(ssrs)* <- org5(not ssrs) <- s4(not otf)
      @org5 = create(:organization, process_ssrs: false, parent: @org3)
      @s4   = create(:service, organization: @org5, one_time_fee: false)
      @li4  = create(:line_item, service: @s4, service_request: @sr)
      @liv4 = create(:line_items_visit, arm: @arm, line_item: @li4)

      @service_list = @arm.reload.service_list
      # (*) These organizations should be the keys of @service_list
    end

    context 'non-one time fee Service does not have a SSRS Organization as a parent' do
      it 'should key Service and its LineItem by its parent Organization\'s id' do
        expect(@service_list.keys).to include(@org2.id)
        expect(@service_list[@org2.id][:services]).to eq [@s1]
        expect(@service_list[@org2.id][:line_items]).to eq [@li1]
      end

      it 'should return abbreviations for all parent Organizations' do
        expect(@service_list[@org2.id][:name]).to eq(@org1.abbreviation + ' -- ' + @org2.abbreviation)
      end

      it 'should return full name for this Organization' do
        expect(@service_list[@org2.id][:process_ssr_organization_name]).to eq @org2.name
      end

      it 'should return ack languages for all parent Organizations' do
        expect(@service_list[@org2.id][:acks].sort).to eq [@org1.ack_language, @org2.ack_language].sort
      end
    end

    context 'one time fee Service' do
      it 'should not return Service or its LineItem' do
        expect(@service_list.values.none? { |x| (x[:services].include? @s2) || (x[:line_items].include? @li2) }).to eq true
      end
    end

    context 'Service has an SSRS Organization as a parent' do
      it 'should key Service and its LineItem by its topmost such parent Organization\'s id' do
        expect(@service_list.keys).to include(@org3.id)
        expect(@service_list[@org3.id][:services].sort).to eq [@s3, @s4].sort
        expect(@service_list[@org3.id][:line_items].sort).to eq [@li3, @li4].sort
      end

      it 'should return the abbreviated name for this Organization' do
        expect(@service_list[@org3.id][:name]).to eq @org3.abbreviation
      end

      it 'should return full name for this Organization' do
        expect(@service_list[@org3.id][:process_ssr_organization_name]).to eq @org3.name
      end

      it 'should return ack language for this Organization' do
        expect(@service_list[@org3.id][:acks]).to eq [@org3.ack_language]
      end
    end
  end
end
