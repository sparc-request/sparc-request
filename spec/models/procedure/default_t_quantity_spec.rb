require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }
  
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
end
