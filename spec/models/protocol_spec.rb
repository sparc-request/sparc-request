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
require 'spec_helper'

describe 'Protocol' do

  describe '.has_at_least_one_sub_service_request_in_cwf?' do

    before do
      @protocol = FactoryGirl.build(:protocol)
      @protocol.save validate: false

      @service_request = FactoryGirl.build(:service_request, protocol: @protocol)
      @service_request.save validate: false
    end

    context 'Protocol has at least one SubServiceRequest in CWF' do

      before do
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)

        sub_service_request = FactoryGirl.build(:sub_service_request,
                                                service_request: @service_request,
                                                in_work_fulfillment: true)
        sub_service_request.save validate: false
      end

      it 'should return: true' do
        expect(@protocol.has_at_least_one_sub_service_request_in_cwf?).to be
      end
    end

    context 'Protocol has no SubServiceRequest in CWF' do

      before do
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)

        sub_service_request = FactoryGirl.build(:sub_service_request,
                                                service_request: @service_request,
                                                in_work_fulfillment: false)
        sub_service_request.save validate: false
      end

      it 'should return: false' do
        expect(@protocol.has_at_least_one_sub_service_request_in_cwf?).to_not be
      end
    end
  end

  describe 'funding_source_based_on_status' do
    it 'should return the potential funding source if funding status is pending_funding' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'pending_funding'
      study.funding_source = 'college'
      study.potential_funding_source = 'foundation'
      study.funding_source_based_on_status.should eq 'foundation'
    end

    it 'should return the funding source if funding status is funded' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'funded'
      study.funding_source = 'college'
      study.potential_funding_source = 'foundation'
      study.funding_source_based_on_status.should eq 'college'
    end
  end

  describe 'should validate funding status and source for studies' do
    it 'should raise an exception if funding status is nil' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = nil
      lambda { study.funding_source_based_on_status }.should raise_exception ArgumentError
    end

    it 'should raise an exception if funding status is neither funded nor pending_funding' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'foobarbaz'
      lambda { study.funding_source_based_on_status }.should raise_exception ArgumentError
    end
  end

  describe 'should validate funding source for projects' do
    it 'should raise an exception if funding source is nil' do
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.funding_source = nil
      project.valid?.should eq false
    end
  end

  describe "push to epic" do
    it "should create a record of the protocols push" do
      human_subjects_info = FactoryGirl.build(:human_subjects_info, pro_number: nil, hr_number: nil)
      study = FactoryGirl.build(:study, human_subjects_info: human_subjects_info)
      study.save(validate: false)
      expect{ study.push_to_epic(EPIC_INTERFACE) }.to change(EpicQueueRecord, :count).by(1)
    end
  end
end

