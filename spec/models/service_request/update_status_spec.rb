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

RSpec.describe ServiceRequest, type: :model do
  let_there_be_lane
  let_there_be_j

  describe "#update_status" do
    context "new_status.to eq('submitted')" do
      context "current status is updatable ('draft') and past_status is nil indicating a newly created SSR" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_updatable_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
          @sr.reload
        end

        it "should return the id of the ssr that was not previously submitted" do
          expect(@sr.update_status('submitted')).to eq([@ssr_updatable_status.id])
        end

        it "should update the status of the SSR to submitted" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.status).to eq('submitted')
        end

        it "should update the status of the SR to submitted" do
          @sr.update_status('submitted')
          expect(@sr.reload.status).to eq('submitted')
        end

        it "should update the submitted_at" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.submitted_at).not_to eq(nil)
        end

        it "should update the nursing_nutrition_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.nursing_nutrition_approved).to eq(false)
        end

        it "should update the lab_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.lab_approved).to eq(false)
        end

        it "should update the imaging_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.imaging_approved).to eq(false)
        end

        it "should update the committee_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.committee_approved).to eq(false)
        end
      end

      context "past status is updatable ('draft') and past_status is also updatable ('get_a_cost_estimate')" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_updatable_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
          PastStatus.create(sub_service_request_id: @ssr_updatable_status.id, status: 'get_a_cost_estimate')
          @sr.reload
        end

        it "should return the id of the ssr that was not previously submitted" do
          expect(@sr.update_status('submitted')).to eq([@ssr_updatable_status.id])
        end

        it "should update the status of the SSR to submitted" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.status).to eq('submitted')
        end

        it "should update the status of the SR to submitted" do
          @sr.update_status('submitted')
          expect(@sr.reload.status).to eq('submitted')
        end

        it "should update the submitted_at" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.submitted_at).not_to eq(nil)
        end

        it "should update the nursing_nutrition_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.nursing_nutrition_approved).to eq(false)
        end

        it "should update the lab_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.lab_approved).to eq(false)
        end

        it "should update the imaging_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.imaging_approved).to eq(false)
        end

        it "should update the committee_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.committee_approved).to eq(false)
        end
      end

      context "past status is updatable ('get_a_cost_estimate')" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_updatable_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'get_a_cost_estimate', submitted_at: nil)
          @sr.reload
        end

        it "should return the id of the ssr that was not previously submitted" do
          expect(@sr.update_status('submitted')).to eq([@ssr_updatable_status.id])
        end

        it "should update the status of the SSR to submitted" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.status).to eq('submitted')
        end

        it "should update the status of the SR to submitted" do
          @sr.update_status('submitted')
          expect(@sr.reload.status).to eq('submitted')
        end

        it "should update the submitted_at" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.submitted_at).not_to eq(nil)
        end

        it "should update the nursing_nutrition_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.nursing_nutrition_approved).to eq(false)
        end

        it "should update the lab_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.lab_approved).to eq(false)
        end

        it "should update the imaging_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.imaging_approved).to eq(false)
        end

        it "should update the committee_approved" do
          @sr.update_status('submitted')
          expect(@ssr_updatable_status.reload.committee_approved).to eq(false)
        end
      end

      context "current status is unupdatable" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_un_updatable_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'on_hold', submitted_at: nil, nursing_nutrition_approved: nil, lab_approved: nil, imaging_approved: nil, committee_approved: nil)
          @sr.reload
        end

        context "updating status to 'get_a_cost_estimate'" do
          it "should return an array with ssr id" do
            expect(@sr.update_status('get_a_cost_estimate')).to eq([@ssr_un_updatable_status.id])
          end

          it "should not update the status of the SSR to submitted" do
            @sr.update_status('get_a_cost_estimate')
            expect(@ssr_un_updatable_status.reload.status).to eq('get_a_cost_estimate')
          end

          it "should update the status of the SR to submitted" do
            @sr.update_status('get_a_cost_estimate')
            expect(@sr.reload.status).to eq('get_a_cost_estimate')
          end

          it "should not update the submitted_at" do
            @sr.update_status('get_a_cost_estimate')
            expect(@ssr_un_updatable_status.reload.submitted_at).to eq(@ssr_un_updatable_status.submitted_at)
          end
        end

        context "updating status to 'submitted'" do
          it "should return an empty array" do
            expect(@sr.update_status('submitted')).to eq([])
          end

          it "should not update the status of the SSR to submitted" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.status).to eq('on_hold')
          end

          it "should update the status of the SR to submitted" do
            @sr.update_status('submitted')
            expect(@sr.reload.status).to eq('submitted')
          end

          it "should not update the submitted_at" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.submitted_at).to eq(nil)
          end

          it "should update the nursing_nutrition_approved" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.nursing_nutrition_approved).to eq(nil)
          end

          it "should update the lab_approved" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.lab_approved).to eq(nil)
          end

          it "should update the imaging_approved" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.imaging_approved).to eq(nil)
          end

          it "should update the committee_approved" do
            @sr.update_status('submitted')
            expect(@ssr_un_updatable_status.reload.committee_approved).to eq(nil)
          end
        end
      end

      context "current status is the same as 'submitted'" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_same_status_as_updated_to_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
          @sr.reload
        end

        it "should return an empty array" do
          expect(@sr.update_status('submitted')).to eq([])
        end

        it "should not update the status of the SSR to submitted" do
          @sr.update_status('submitted')
          expect(@ssr_same_status_as_updated_to_status.reload.status).to eq('submitted')
        end

        it "should update the status of the SR to submitted" do
          @sr.update_status('submitted')
          expect(@sr.reload.status).to eq('submitted')
        end

        it "should not update the submitted_at" do
          @sr.update_status('submitted')
          expect(@ssr_same_status_as_updated_to_status.reload.submitted_at).to eq(@ssr_same_status_as_updated_to_status.submitted_at)
        end
      end

      ### Pivotal Tracker Story:  #135639799
      context "current status is 'submitted'" do
        before :each do
          @org         = create(:organization_with_process_ssrs)
          identity     = create(:identity)
          service     = create(:service, organization: @org, one_time_fee: true)
          protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
          @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
          @ssr_with_submitted_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
          @sr.reload
        end

        context "updating status to 'get_a_cost_estimate'" do
          it "should return an array with ssr id" do
            expect(@sr.update_status('get_a_cost_estimate')).to eq([@ssr_with_submitted_status.id])
          end

          it "should not update the status of the SSR to submitted" do
            @sr.update_status('get_a_cost_estimate')
            expect(@ssr_with_submitted_status.reload.status).to eq('get_a_cost_estimate')
          end

          it "should update the status of the SR to submitted" do
            @sr.update_status('get_a_cost_estimate')
            expect(@sr.reload.status).to eq('get_a_cost_estimate')
          end

          it "should not update the submitted_at" do
            @sr.update_status('get_a_cost_estimate')
            expect(@ssr_with_submitted_status.reload.submitted_at).to eq(@ssr_with_submitted_status.submitted_at)
          end
        end

        context "updating status to 'draft'" do
          it "should return an array with ssr id" do
            expect(@sr.update_status('draft')).to eq([@ssr_with_submitted_status.id])
          end

          it "should not update the status of the SSR to submitted" do
            @sr.update_status('draft')
            expect(@ssr_with_submitted_status.reload.status).to eq('draft')
          end

          it "should update the status of the SR to submitted" do
            @sr.update_status('draft')
            expect(@sr.reload.status).to eq('draft')
          end

          it "should not update the submitted_at" do
            @sr.update_status('draft')
            expect(@ssr_with_submitted_status.reload.submitted_at).to eq(@ssr_with_submitted_status.submitted_at)
          end
        end
      end
    end

    context "updatable status to 'get_a_cost_estimate'" do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        identity     = create(:identity)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr_updatable_status   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: Time.now.yesterday.utc)
        @sr.reload
      end

      it "should return the id of the ssr that was not previously submitted" do
        expect(@sr.update_status('get_a_cost_estimate')).to eq([@ssr_updatable_status.id])
      end

      it "should update the status of the SSR to submitted" do
        @sr.update_status('get_a_cost_estimate')
        expect(@ssr_updatable_status.reload.status).to eq('get_a_cost_estimate')
      end

      it "should update the status of the SR to submitted" do
        @sr.update_status('get_a_cost_estimate')
        expect(@sr.reload.status).to eq('get_a_cost_estimate')
      end
    end

    context "past status same as status being updated to" do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        identity     = create(:identity)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol_id: protocol.id, submitted_at: Time.now.yesterday.utc)
        @ssr_updatable_status   = create(:sub_service_request, service_request_id: @sr.id, organization_id: @org.id, status: 'draft', submitted_at: Time.now.yesterday.utc)
        @sr.reload
        PastStatus.create(sub_service_request_id: @ssr_updatable_status.id, status: 'get_a_cost_estimate')
      end

      it "should return the id of the ssr that was not previously submitted" do
        expect(@sr.update_status('get_a_cost_estimate')).to eq([@ssr_updatable_status.id])
      end

      it "should update the status of the SSR to submitted" do
        @sr.update_status('get_a_cost_estimate')
        expect(@ssr_updatable_status.reload.status).to eq('get_a_cost_estimate')
      end

      it "should update the status of the SR to submitted" do
        @sr.update_status('get_a_cost_estimate')
        expect(@sr.reload.status).to eq('get_a_cost_estimate')
      end
    end
  end
end
