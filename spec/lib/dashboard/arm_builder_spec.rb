require "rails_helper"

RSpec.describe Dashboard::ArmBuilder do
  describe "#initialize" do
    it "should create a new Arm" do
      allow(Arm).to receive(:create)
      attrs = { some_attr: :some_value }

      Dashboard::ArmBuilder.new(attrs)

      expect(Arm).to have_received(:create).with(attrs)
    end
  end

  describe "#build" do
    context "with attributes describing valid Arm" do
      it "should create LineItemsVisits for each PPPV LineItem associated with the Protocol" do
        protocol = build_stubbed(:protocol)
        stub_find_protocol(protocol)
        service_request = build_stubbed(:service_request, protocol_id: protocol.id)
        allow(protocol).to receive(:service_requests).and_return([service_request])
        pppv_line_item = instance_double(LineItem)
        allow(service_request).to receive(:per_patient_per_visit_line_items).and_return([pppv_line_item])

        # spy on new Arm's #create_line_items_visit
        attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        new_arm = Arm.create(attrs)
        allow(new_arm).to receive(:create_line_items_visit)
        allow(Arm).to receive(:create).with(attrs).and_return(new_arm)

        builder = Dashboard::ArmBuilder.new(attrs)
        builder.build

        expect(new_arm).to have_received(:create_line_items_visit).with(pppv_line_item)
      end

      it "should set default visit days on associated VisitGroups" do
        protocol = build_stubbed(:protocol)
        stub_find_protocol(protocol)

        # spy on new Arm's #default_visit_days
        attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        new_arm = Arm.create(attrs)
        allow(new_arm).to receive(:default_visit_days)
        allow(Arm).to receive(:create).with(attrs).and_return(new_arm)

        builder = Dashboard::ArmBuilder.new(attrs)
        builder.build

        expect(new_arm).to have_received(:default_visit_days)
      end

      it "#arm should return a valid Arm after #build" do
        protocol = build_stubbed(:protocol)
        stub_find_protocol(protocol)

        attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        builder = Dashboard::ArmBuilder.new(attrs)
        builder.build

        expect(builder.arm.class.name).to eq("Arm")
        expect(builder.arm).to be_valid
      end

      context 'Protocol has SubServiceRequests in CWF' do
        it 'should populate subjects for new Arm' do
          # stub Protocol with SubServiceRequests in CWF
          protocol = build_stubbed(:protocol)
          ssr_in_cwf = instance_double(SubServiceRequest, in_work_fulfillment: true)
          allow(protocol).to receive(:sub_service_requests).and_return([ssr_in_cwf])
          stub_find_protocol(protocol)

          # spy on new Arm's #populate_subjects
          attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
          new_arm = Arm.create(attrs)
          allow(new_arm).to receive(:populate_subjects)
          allow(Arm).to receive(:create).with(attrs).and_return(new_arm)

          Dashboard::ArmBuilder.new(attrs).build

          expect(new_arm).to have_received(:populate_subjects)
        end
      end

      context 'Protocol has no SubServiceRequests in CWF' do
        it 'should not populate subjects for new Arm' do
          # stub Protocol with SubServiceRequests in CWF
          protocol = build_stubbed(:protocol)
          ssr_in_cwf = instance_double(SubServiceRequest, in_work_fulfillment: false)
          allow(protocol).to receive(:sub_service_requests).and_return([ssr_in_cwf])
          stub_find_protocol(protocol)

          # spy on new Arm's #populate_subjects
          attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
          new_arm = Arm.create(attrs)
          allow(new_arm).to receive(:populate_subjects)
          allow(Arm).to receive(:create).with(attrs).and_return(new_arm)

          Dashboard::ArmBuilder.new(attrs).build

          expect(new_arm).not_to have_received(:populate_subjects)
        end
      end
    end
  end

  def stub_find_protocol(stub)
    allow(Protocol).to receive(:find).with(stub.id).and_return(stub)
  end
end
