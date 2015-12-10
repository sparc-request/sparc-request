require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }
  let!(:sr)          { create(:service_request_without_validations) }

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

end
