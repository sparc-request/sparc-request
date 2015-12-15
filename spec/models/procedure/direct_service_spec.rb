
require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }
  let!(:sr)          { create(:service_request_without_validations) }

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
end
