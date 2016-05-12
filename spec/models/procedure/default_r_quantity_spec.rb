require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }

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
      let!(:arm)    { create(:arm) }
      let!(:vg)     { create(:visit_group, arm: arm) }

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
end
