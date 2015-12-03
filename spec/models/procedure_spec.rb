# coding: utf-8
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

require 'rails_helper'

RSpec.describe 'procedure' do
  # let!(:arm) { create(:arm, name: 'Arm IV', protocol_id: protocol_for_service_request_id, visit_count: 1, subject_count: 1) }
  # let!(:visit_group) { create(:visit_group, arm_id: arm.id) }
  # let!(:visit) { create(:visit, research_billing_qty: 10, insurance_billing_qty: 10, visit_group_id: visit_group.id) }
  # let!(:appointment) { create(:appointment, visit_group_id: visit_group.id) }
  # let(:procedure) { create(:procedure, appointment_id: appointment.id, visit_id: visit.id, line_item_id: line_item.id) }
  # let(:procedure2) { create(:procedure, appointment_id: appointment.id, visit_id: visit.id, service_id: service2.id) }
  # let(:procedure3) { create(:procedure, appointment_id: appointment.id, visit_id: visit.id, service_id: service2.id, line_item_id: line_item.id) }

  let!(:appointment) { Appointment.create }
  let!(:sr)          { create(:service_request_without_validations) }

  describe '#required?' do
    let!(:arm) { Arm.create }
    let!(:vg)  { VisitGroup.create(arm_id: arm.id) }

    context 'Visit has research_billing_qty = 0' do
      let!(:visit)     { Visit.create(research_billing_qty: 0, visit_group_id: vg.id) }
      let!(:procedure) { Procedure.create(appointment_id: appointment.id, visit_id: visit.id) }

      it 'should return false' do
        expect(procedure.required?).to eq(false)
      end
    end

    context 'Visit has research_billing_qty > 0' do
      let!(:visit)     { Visit.create(research_billing_qty: 1, visit_group_id: vg.id) }
      let!(:procedure) { Procedure.create(appointment_id: appointment.id, visit_id: visit.id) }

      it 'should return true' do
        expect(procedure.required?).to eq(true)
      end
    end
  end

  describe '#display_service_name' do
    context 'Procedure does not belong to a Service' do
      context 'but belongs to a LineItem' do
        context 'LineItem belongs to a Service' do
          let!(:li)        { create(:line_item_with_service, service_request: sr) }
          let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id) }

          it 'should return the name of the LineItem\'s Service' do
            expect(procedure.display_service_name).to eq(li.service.name)
          end
        end

        context 'LineItem does not belong to a Service' do
          let!(:li) do
            li = build(:line_item, service_request: sr)
            li.save(validate: false)
            li
          end
          let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id) }

          it 'should return nil' do
            expect(procedure.display_service_name).to eq(nil)
          end
        end
      end

      context 'but also does not belong to a LineItem' do
        let!(:procedure) { Procedure.create(appointment_id: appointment.id) }

        it 'should return nil' do
          expect(procedure.display_service_name).to eq(nil)
        end
      end
    end

    context 'Procedure belongs to a Service' do
      context 'and belongs to a LineItem' do
        let!(:li)        { create(:line_item_with_service, service_request: sr) }
        let!(:service)   { create(:service, name: '!' + li.service.name) }
        let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id, service_id: service.id) }

        it 'should return the name of the Service' do
          expect(procedure.display_service_name).to eq(service.name)
        end
      end

      context 'but does not belong to a LineItem' do
        let!(:service)   { create(:service) }
        let!(:procedure) { Procedure.create(appointment_id: appointment.id, service_id: service.id) }

        it 'should return the name of the Service' do
          expect(procedure.display_service_name).to eq(service.name)
        end
      end
    end
  end

  describe '#direct_service' do
    context 'Procedure does not belong to a Service but belongs to a LineItem' do
      let!(:li)        { create(:line_item_with_service, service_request: sr) }
      let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id) }

      it 'should return the the LineItem\'s Service' do
        expect(procedure.direct_service).to eq(li.service)
      end
    end

    context 'Procedure belongs to a Service' do
      context 'and belongs to a LineItem' do
        let!(:li)        { create(:line_item_with_service, service_request: sr) }
        let!(:service)   { create(:service) }
        let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id, service_id: service.id) }

        it 'should return the Service' do
          expect(procedure.direct_service).to eq(service)
        end
      end

      context 'but does not belong to a LineItem' do
        let!(:service)   { create(:service) }
        let!(:procedure) { Procedure.create(appointment_id: appointment.id, service_id: service.id) }

        it 'should return the Service' do
          expect(procedure.direct_service).to eq(service)
        end
      end
    end
  end

  describe '#core' do
    context 'Procedure belongs to a Service but not a LineItem' do
      let!(:core)      { Core.create }
      let!(:service)   { create(:service, organization_id: core.id) }
      let!(:procedure) { Procedure.create(appointment_id: appointment.id, service_id: service.id) }

      it 'should return the Core of the Service' do
        expect(procedure.core).to eq(core)
      end
    end

    context 'Procedure belongs to a LineItem but not a Service' do
      let!(:core) { Core.create }
      let!(:li) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.update_attributes(organization_id: core.id)
        li
      end
      let!(:procedure) { Procedure.create(appointment_id: appointment.id, line_item_id: li.id) }

      it 'should return the core of the LineItem\'s Service' do
        expect(procedure.core).to eq(core)
      end
    end

    context 'Procedure belongs to both a Service and LineItem' do
      let!(:li_core) { Core.create }
      let!(:li) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.update_attributes(organization_id: li_core.id)
        li
      end
      let!(:service_core) { Core.create }
      let!(:service)      { create(:service, organization_id: service_core.id) }
      let!(:procedure)    { Procedure.create(appointment_id: appointment.id, line_item_id: li.id, service_id: service.id) }

      it 'should return the Core of the Service' do
        expect(procedure.core).to eq(service_core)
      end
    end
  end

  describe '#default_r_quantity' do
    let!(:procedure) { Procedure.create(appointment_id: appointment.id) }

    shared_examples 'r_quantity' do
      it 'should return r_quantity' do
        expect(procedure.default_r_quantity).to eq(procedure.r_quantity)
      end
    end

    context 'Appointment does not have a VisitGroup' do
      context 'Procedure belongs to a Service' do
        let!(:service) { create(:service_with_pricing_map) }
        before(:each)  { procedure.update_attributes(service_id: service.id) }

        context 'r_quantity set' do
          before(:each) { procedure.update_attributes(r_quantity: 255) }
          it_behaves_like 'r_quantity'
        end

        context 'r_quantity not set' do
          it_behaves_like 'r_quantity'
        end
      end

      context 'Procedure does not belong to a Service' do
        context 'r_quantity set' do
          before(:each) { procedure.update_attributes(r_quantity: 255) }

          it_behaves_like 'r_quantity'
        end

        context 'r_quantity not set' do
          it_behaves_like 'r_quantity'
        end
      end
    end

    context 'Appointment has a VisitGroup' do
      let!(:arm)    { Arm.create }
      let!(:vg)     { VisitGroup.create(arm_id: arm.id) }

      before(:each) do
        appointment.update_attributes(visit_group_id: vg.id)
        procedure.appointment.reload
      end

      context 'Procedure belongs to a Service' do
        let!(:service) { create(:service_with_pricing_map) }
        before(:each)  { procedure.update_attributes(service_id: service.id) }

        context 'r_quantity set' do
          before(:each) { procedure.update_attributes(r_quantity: 255) }

          it_behaves_like 'r_quantity'
        end

        context 'r_quantity not set' do
          let!(:visit)  { Visit.create(visit_group_id: vg.id, research_billing_qty: 511) }
          before(:each) { procedure.update_attributes(visit_id: visit.id) }

          it 'should return 0' do
            expect(procedure.default_r_quantity).to eq(0)
          end
        end
      end

      context 'Procedure does not belong to a Service' do
        context 'r_quantity set' do
          before(:each) { procedure.update_attributes(r_quantity: 255) }

          it_behaves_like 'r_quantity'
        end

        context 'r_quantity not set' do
          let!(:visit)  { Visit.create(visit_group_id: vg.id, research_billing_qty: 511) }
          before(:each) { procedure.update_attributes(visit_id: visit.id) }

          it 'should return Visit\'s research_billing_qty' do
            expect(procedure.default_r_quantity).to eq(511)
          end
        end
      end
    end
  end

  describe '#default_t_quantity' do
    let!(:procedure) { Procedure.create(appointment_id: appointment.id) }

    shared_examples 't_quantity' do
      it 'should return t_quantity' do
        expect(procedure.default_t_quantity).to eq(procedure.t_quantity)
      end
    end

    context 'Appointment does not have a VisitGroup' do
      context 'Procedure belongs to a Service' do
        let!(:service) { create(:service_with_pricing_map) }
        before(:each)  { procedure.update_attributes(service_id: service.id) }

        context 't_quantity set' do
          before(:each) { procedure.update_attributes(t_quantity: 255) }
          it_behaves_like 't_quantity'
        end

        context 't_quantity not set' do
          it_behaves_like 't_quantity'
        end
      end

      context 'Procedure does not belong to a Service' do
        context 't_quantity set' do
          before(:each) { procedure.update_attributes(t_quantity: 255) }

          it_behaves_like 't_quantity'
        end

        context 't_quantity not set' do
          it_behaves_like 't_quantity'
        end
      end
    end

    context 'Appointment has a VisitGroup' do
      let!(:arm)    { Arm.create }
      let!(:vg)     { VisitGroup.create(arm_id: arm.id) }

      before(:each) do
        appointment.update_attributes(visit_group_id: vg.id)
        procedure.appointment.reload
      end

      context 'Procedure belongs to a Service' do
        let!(:service) { create(:service_with_pricing_map) }
        before(:each)  { procedure.update_attributes(service_id: service.id) }

        context 't_quantity set' do
          before(:each) { procedure.update_attributes(t_quantity: 255) }

          it_behaves_like 't_quantity'
        end

        context 't_quantity not set' do
          let!(:visit)  { Visit.create(visit_group_id: vg.id, insurance_billing_qty: 511) }
          before(:each) { procedure.update_attributes(visit_id: visit.id) }

          it 'should return 0' do
            expect(procedure.default_t_quantity).to eq(0)
          end
        end
      end

      context 'Procedure does not belong to a Service' do
        context 't_quantity set' do
          before(:each) { procedure.update_attributes(t_quantity: 255) }

          it_behaves_like 't_quantity'
        end

        context 't_quantity not set' do
          let!(:visit)  { Visit.create(visit_group_id: vg.id, insurance_billing_qty: 511) }
          before(:each) { procedure.update_attributes(visit_id: visit.id) }

          it 'should return Visit\'s insurance_billing_qty' do
            expect(procedure.default_t_quantity).to eq(511)
          end
        end
      end
    end
  end

  describe '#default insurance quantity' do
    context 'when attached to a line item' do
      it "should return the visit's insurance billing quantity if not set" do
        expect(procedure.default_t_quantity).to eq(10)
      end
      it 'should return its own quantity if set' do
        procedure.update_attributes(t_quantity: 5)
        expect(procedure.default_t_quantity).to eq(5)
      end
    end

    context 'when attached to a service' do
      it 'should return zero if quantity is not set' do
        expect(procedure2.default_t_quantity).to eq(0)
      end
      it 'should return its own quantity if set' do
        procedure2.update_attributes(t_quantity: 5)
        expect(procedure2.default_t_quantity).to eq(5)
      end
    end
  end

  describe 'cost' do
    it 'should return the cost when attached to a line item' do
      expect(procedure.cost).to eq(10.0)
    end

    it 'should return the cost when attached to a service' do
      expect(procedure.cost).to eq(10.0)
    end
  end
end
