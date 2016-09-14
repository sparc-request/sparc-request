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

require "rails_helper"

RSpec.describe Dashboard::ArmBuilder do
  context "with attributes describing valid Arm, Protocol has SubServiceRequests in fulfillment" do
    before(:each) do
      # stub a Protocol with fulfillments and a per patient, per visit LineItem
      protocol = findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          sub_service_requests: [instance_double(SubServiceRequest, in_work_fulfillment: true)])
      end
      service_request = build_stubbed(:service_request)
      allow(protocol).to receive(:service_requests).and_return([service_request])
      allow(service_request).to receive(:per_patient_per_visit_line_items).and_return(["PPPVLineItem"])

      # stub a valid Arm for Arm.create
      @new_arm = instance_double(Arm, valid?: true)
      arm_attributes_for_creation = { protocol_id: 1, other_attributes: "here" }
      allow(Arm).to receive(:create).with(arm_attributes_for_creation).and_return(@new_arm)

      # test for proper Arm setup, in this order
      # TODO find a way to move these expectations into individual examples
      expect(@new_arm).to receive(:create_line_items_visit).with("PPPVLineItem").ordered
      expect(@new_arm).to receive(:default_visit_days).ordered
      expect(@new_arm).to receive(:populate_subjects).ordered

      @builder = Dashboard::ArmBuilder.new(arm_attributes_for_creation)
    end

    it "should set :arm to created Arm, with a LineItemsVisit for each PPV LineItem under Protocol, default visit days, and populated subjects" do
      expect(@builder.arm).to eq(@new_arm)
    end
  end

  context "with attributes describing valid Arm, Protocol has no SubServiceRequests in fulfillment" do
    before(:each) do
      # stub a Protocol with no fulfillments and a per patient, per visit LineItem
      protocol = findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          sub_service_requests: [instance_double(SubServiceRequest, in_work_fulfillment: false)])
      end
      service_request = build_stubbed(:service_request)
      allow(protocol).to receive(:service_requests).
        and_return([service_request])
      allow(service_request).to receive(:per_patient_per_visit_line_items).
        and_return(["PPPVLineItem"])

      # stub a valid Arm for Arm.create
      @new_arm = instance_double(Arm, valid?: true)
      arm_attributes_for_creation = { protocol_id: 1, other_attributes: "here" }
      allow(Arm).to receive(:create).
        with(arm_attributes_for_creation).
        and_return(@new_arm)

      # test for proper Arm setup, in this order
      # TODO find a way to move these expectations into individual examples
      allow(@new_arm).to receive(:create_line_items_visit).with("PPPVLineItem").ordered
      expect(@new_arm).to receive(:default_visit_days).ordered
      allow(@new_arm).to receive(:populate_subjects)

      @builder = Dashboard::ArmBuilder.new(arm_attributes_for_creation)
    end

    it "should set :arm to created Arm, with a LineItemsVisit for each PPV LineItem under Protocol, and default visit days" do
      expect(@builder.arm).to eq(@new_arm)
    end

    it "should not populate subjects for new Arm" do
      expect(@new_arm).not_to have_received(:populate_subjects)
    end
  end

  context "with attributes describing invalid Arm" do
    before(:each) do
      # stub an invalid Arm for Arm.create
      @new_arm = instance_double(Arm, valid?: false)
      arm_attributes_for_creation = { protocol_id: 1, other_attributes: "here" }
      allow(Arm).to receive(:create).
        with(arm_attributes_for_creation).
        and_return(@new_arm)

      allow(@new_arm).to receive(:create_line_items_visit)
      allow(@new_arm).to receive(:default_visit_days)
      allow(@new_arm).to receive(:populate_subjects)

      @builder = Dashboard::ArmBuilder.new(arm_attributes_for_creation)
    end

    it "should set :arm to created Arm" do
      expect(@builder.arm).to eq(@new_arm)
    end

    it "should not perform any setup on new Arm" do
      expect(@new_arm).not_to have_received(:create_line_items_visit)
      expect(@new_arm).not_to have_received(:default_visit_days)
      expect(@new_arm).not_to have_received(:populate_subjects)
    end
  end
end
