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

RSpec.describe OncoreEndpointController do
  render_views
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'app', Rails.application

  let_there_be_lane

  before :each do
    @study    = create(:study_federally_funded, research_master_id: 1234, primary_pi: jug2)
    sr        = create(:service_request, protocol: @study)
    default_service = create(:service_with_process_ssrs_organization, :with_pricing_map, id: 41714, name: "OnCore Procedure Push", cpt_code: "00000")
    @wsdl     = "http://app#{oncore_endpoint_wsdl_path}"
    @client   = Savon.client(wsdl: @wsdl)
    @crpc_message = crpc_message(@study) # CRPC message with 2 arms, 3 VISITS per arm (not SPARC Visits), and 2 Procedures
    @rpe_message = rpe_message(@study) # RPE message (CRPC message without calendar information)
  end
  
  describe '#retrieve_protocol_def CRPC message' do
    it 'should import the service calendar structure' do
      @client.call(:retrieve_protocol_def_response, message: @crpc_message)
      expect(@study.arms.count).to eq(2)
      # TODO: Once chargemaster is fixed, it should import procedures/services.
      # It should not bring in any procedures at the moment, even if they are present
      # expect(@study.line_items.count).to eq(2)
      # expect(@study.line_items_visits.count).to eq(4)
      # expect(@study.visits.count).to eq(12)
      expect(@study.line_items.count).to eq(1) # Instead, use the temporary default OnCore Push service.
      expect(@study.line_items_visits.count).to eq(2)
      expect(@study.visit_groups.count).to eq(6) # Visit groups stays the same
      expect(@study.visits.count).to eq(6)
    end

    it 'should set the Visit Group day, window before, and window after' do
      @client.call(:retrieve_protocol_def_response, message: @crpc_message)
      visit_group1 = @study.arms.first.visit_groups[0]
      visit_group3 = @study.arms.first.visit_groups[2]
      expect(visit_group1.day).to eq(1)
      expect(visit_group1.window_before).to eq(0)
      expect(visit_group1.window_after).to eq(0)
      expect(visit_group3.day).to eq(10)
      expect(visit_group3.window_before).to eq(3)
      expect(visit_group3.window_after).to eq(3)
    end

    it 'should render a SOAP fault if there is an error' do
      begin
        @client.call(:retrieve_protocol_def_response, message: crpc_message(@study, "nonexistant_rmid"))
      rescue Savon::Error => error
        expect(error.instance_of?(Savon::SOAPFault)).to eq(true)
      end
    end
  end

  describe '#retrieve_protocol_def_response CRPC message without procedures' do
    it 'should import the service calendar structure' do
      @client.call(:retrieve_protocol_def_response, message: crpc_message_without_procedures(@study))
      expect(@study.arms.count).to eq(2)
      expect(@study.line_items.count).to eq(1)
      expect(@study.line_items_visits.count).to eq(2)
      expect(@study.visit_groups.count).to eq(6)
      expect(@study.visits.count).to eq(6)
    end

    it 'should set the Visit Group day, window before, and window after' do
      @client.call(:retrieve_protocol_def_response, message: crpc_message_without_procedures(@study))
      visit_group1 = @study.arms.first.visit_groups[0]
      visit_group3 = @study.arms.first.visit_groups[2]
      expect(visit_group1.day).to eq(1)
      expect(visit_group1.window_before).to eq(0)
      expect(visit_group1.window_after).to eq(0)
      expect(visit_group3.day).to eq(10)
      expect(visit_group3.window_before).to eq(3)
      expect(visit_group3.window_after).to eq(3)
    end
  end

  describe '#retrieve_protocol_def RPE message' do
    it 'should not import any calendar information' do
      @client.call(:retrieve_protocol_def_response, message: @rpe_message)
      expect(@study.arms.count).to eq(0)
      expect(@study.line_items.count).to eq(0)
      expect(@study.line_items_visits.count).to eq(0)
      expect(@study.visit_groups.count).to eq(0)
      expect(@study.visits.count).to eq(0)
    end
  end
end
