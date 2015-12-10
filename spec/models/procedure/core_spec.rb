require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }
  let!(:sr)          { create(:service_request_without_validations) }

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
end
