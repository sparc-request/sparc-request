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

require 'date'
require 'rails_helper'

RSpec.describe 'Protocol' do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study()
  build_service_request_with_project()
  build_study_type_question_groups()
  build_study_type_questions()
  build_study_type_answers()

  describe "#with_organization" do
    
    context "return protocols with ssrs that have searched_organization with param of string" do

      before :each do
        @searched_organization = create(:organization)
        @not_searched_organization = create(:organization)
        @another_searched_organization = create(:organization)

        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: @searched_organization)
        
        @protocol2 = create(:study_without_validations)
        @sr2 = create(:service_request_without_validations, protocol_id: @protocol2.id)
        @ssr2 = create(:sub_service_request_without_validations, service_request_id: @sr2.id, organization: @searched_organization)

        @protocol3 = create(:study_without_validations)
        @sr3 = create(:service_request_without_validations, protocol_id: @protocol3.id)
        @ssr3 = create(:sub_service_request_without_validations, service_request_id: @sr3.id, organization: @not_searched_organization)
      end

      it "will return protocols with searched_status" do
        response = Protocol.with_organization("#{@searched_organization.id}")
        protocols_with_searched_for_org = [@protocol1.id, @protocol2.id]
        expect(response.pluck(:id).sort).to eq(protocols_with_searched_for_org)
      end

      it "will return 0 protocols" do
        @ssr1.update_attribute(:organization, @not_searched_organization)
        @ssr2.update_attribute(:organization, @not_searched_organization)
        response = Protocol.with_organization("#{@searched_organization.id}")
        expect(response).to eq []
      end

      it "will return all protocols that have one or more of the multiple searched statuses" do
        @ssr3.update_attribute(:organization, @another_searched_organization)
        response = Protocol.with_organization("#{@searched_organization.id} #{@another_searched_organization.id}")
        protocols_with_searched_for_organization = [@protocol1.id, @protocol2.id, @protocol3.id]
        expect(response.pluck(:id).sort).to eq(protocols_with_searched_for_organization)
      end
    end
    
    context "return protocols with ssrs that have searched_organization with param of array" do

      before :each do
        @searched_organization = create(:organization)
        @not_searched_organization = create(:organization)
        @another_searched_organization = create(:organization)

        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: @searched_organization)
        
        @protocol2 = create(:study_without_validations)
        @sr2 = create(:service_request_without_validations, protocol_id: @protocol2.id)
        @ssr2 = create(:sub_service_request_without_validations, service_request_id: @sr2.id, organization: @searched_organization)

        @protocol3 = create(:study_without_validations)
        @sr3 = create(:service_request_without_validations, protocol_id: @protocol3.id)
        @ssr3 = create(:sub_service_request_without_validations, service_request_id: @sr3.id, organization: @not_searched_organization)
      end

      it "will return protocols with searched_status" do
        response = Protocol.with_organization(["#{@searched_organization.id}"])
        protocols_with_searched_for_org = [@protocol1.id, @protocol2.id]
        expect(response.pluck(:id).sort).to eq(protocols_with_searched_for_org)
      end

      it "will return 0 protocols" do
        @ssr1.update_attribute(:organization, @not_searched_organization)
        @ssr2.update_attribute(:organization, @not_searched_organization)
        response = Protocol.with_organization(["#{@searched_organization.id}"])
        expect(response).to eq []
      end

      it "will return all protocols that have one or more of the multiple searched statuses" do
        @ssr3.update_attribute(:organization, @another_searched_organization)
        response = Protocol.with_organization(["#{@searched_organization.id}", "#{@another_searched_organization.id}"])
        protocols_with_searched_for_organization = [@protocol1.id, @protocol2.id, @protocol3.id]
        expect(response.pluck(:id).sort).to eq(protocols_with_searched_for_organization)
      end
    end
  end
end