# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe SubServiceRequest, type: :model do

  describe "#distribute_surveys" do
    before(:each) { SubServiceRequest.skip_callback(:save, :after, :update_org_tree) }
    after(:each) { SubServiceRequest.set_callback(:save, :after, :update_org_tree) }

    context 'we have available surveys' do
      before :each do
        @pi                   = create(:identity)
        @service_requester    = create(:identity)
        @protocol             = create(:protocol_without_validations, type: "Study", primary_pi: @pi)
        @service_request      = create(:service_request_without_validations, protocol: @protocol)
        @organization         = create(:organization)
        @survey               = create(:system_survey, access_code: 'sctr-customer-satisfaction-survey')
        @sub_service_request  = create(:sub_service_request_without_validations,
                                        service_request: @service_request,
                                        organization: @organization,
                                        service_requester_id:  @service_requester.id,
                                        owner: build(:identity))

        @service              = create(:service_without_validations, organization_id:  @organization.id)
        @line_item            = create(:line_item_without_validations,
                                        service_request_id: @service_request.id,
                                        service_id:  @service.id,
                                        sub_service_request_id: @sub_service_request.id)
        @organization.associated_surveys.create survey_id: @survey.id
      end

      context 'should distribute surveys' do
        context 'when primary pi and ssr requester are uniq' do
          it 'to both primary pi and ssr requester' do
            expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(2)
          end
        end
        context 'when primary pi and ssr requester are the same' do
          it 'to only primary pi' do
            @sub_service_request.update_attribute(:service_requester_id, @pi.id)
            expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end
      end
    end

    context 'we do not have available surveys' do
      before :each do
        @pi                    = create(:identity)
        @service_requester = create(:identity)
        @protocol             = create(:protocol_without_validations)
        create(:project_role, identity_id:  @pi.id, protocol_id:  @protocol.id, role: 'primary-pi')
        @service_request      = create(:service_request_without_validations, protocol: @protocol)
        @organization         = create(:organization)
        @survey               = create(:system_survey, access_code: 'sctr-customer-satisfaction-survey')
        @sub_service_request  = create(:sub_service_request_without_validations,
                                        service_request: @service_request,
                                        organization: @organization,
                                        service_requester_id:  @service_requester.id)
      end

      it 'should not distribute surveys' do
        expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end
end
