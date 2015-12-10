require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let!(:appointment) { Appointment.create }

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
end
