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

RSpec.describe Appointment, type: :model do
  context 'clinical work fulfillment' do
    let!(:core1)        { create(:core) }
    let!(:core2)        { create(:core) }
    let!(:appointment)  { create(:appointment, organization_id: core2.id, completed_at: Date.new(2001, 1, 2)) }

    describe '#formatted_completed_date' do
      context 'completed_at present' do
        it 'should return completed_at in format: -m/%d/%Y' do
          expect(appointment.formatted_completed_date).to eq '1/02/2001'
        end
      end

      context 'completed_at not present' do
        before(:each) { appointment.update_attributes(completed_at: nil) }

        it 'should return nil' do
          expect(appointment.formatted_completed_date).to eq nil
        end
      end
    end

    describe '#formatted_completed_date=' do
      context 'right hand side is a valid date string in the form: %m/%d/%Y' do
        it 'should update completed_at' do
          appointment.formatted_completed_date = '02/01/2000'
          expect(appointment.completed_at).to eq Date.new(2000, 2, 1)
        end
      end

      context 'right hand side is not a valid date string in the form: %m/%d/%Y' do
        it 'should set completed_at to nil' do
          appointment.formatted_completed_date = '13/01/2000'
          expect(appointment.completed_at).to eq nil
        end
      end
    end

    describe '#populate_procedures' do
      let!(:sr)       { create(:service_request_without_validations) }
      let!(:li1) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.organization.tag_list = 'ctrc'
        li.service.update_attributes(one_time_fee: false)
        li
      end
      let!(:li2) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.organization.tag_list = ''
        li.service.update_attributes(one_time_fee: false)
        li
      end
      let!(:li3) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.organization.tag_list = 'ctrc'
        li.service.update_attributes(one_time_fee: true)
        li
      end
      let!(:li4) do
        li = create(:line_item_with_service, service_request: sr)
        li.service.organization.tag_list = ''
        li.service.update_attributes(one_time_fee: true)
        li
      end
      let!(:arm)      { create(:arm) }
      let!(:liv1)     { create(:line_items_visit, arm: arm, line_item: li1) }
      let!(:liv2)     { create(:line_items_visit, arm: arm, line_item: li2) }
      let!(:liv3)     { create(:line_items_visit, arm: arm, line_item: li3) }
      let!(:liv4)     { create(:line_items_visit, arm: arm, line_item: li4) }
      let!(:vg)       { create(:visit_group_without_validations, arm: arm) }
      let!(:visit1)   { create(:visit, line_items_visit: liv1, visit_group: vg) }
      let!(:visit2)   { create(:visit, line_items_visit: liv2, visit_group: vg) }
      let!(:visit3)   { create(:visit, line_items_visit: liv3, visit_group: vg) }
      let!(:visit4)   { create(:visit, line_items_visit: liv4, visit_group: vg) }

      context 'parameter not empty' do
        it 'should import Procedures from Visits associated with a non-one time fee Service belonging to a ctrc Organization' do
          expect(Procedure).to receive(:import).with([:line_item_id, :visit_id, :toasts_generated, :appointment_id], [[li1.id, visit1.id, true, appointment.id]], { validate: true })
          appointment.populate_procedures([visit1, visit2, visit3, visit4])
        end
      end

      context 'parameter empty' do
        it 'should not import any Procedures' do
          expect(Procedure).not_to receive(:import)
          appointment.populate_procedures([])
        end
      end
    end

    describe '#position_switch' do
      context 'Appointment belongs to VisitGroup' do
        let(:arm) { create(:arm) }

        before(:each) do
          vg = create(:visit_group_without_validations, arm: arm, position: 2)
          appointment.update_attributes(visit_group_id: vg.id, position: 1)
        end

        it 'should return the position of the VisitGroup' do
          expect(appointment.position_switch).to eq 2
        end
      end

      context 'Appointment does not belong to VisitGroup' do
        before(:each) { appointment.update_attributes(position: 1) }

        it 'should return the position of the Appointment' do
          expect(appointment.position_switch).to eq 1
        end
      end
    end

    describe '#name_switch' do
      context 'Appointment belongs to VisitGroup' do
        let(:arm) { create(:arm) }

        before(:each) do
          vg = create(:visit_group_without_validations, arm: arm, name: 'VisitGroup Name')
          appointment.update_attributes(visit_group_id: vg.id, name: 'Appointment Name')
        end

        it 'should return the name of the VisitGroup' do
          expect(appointment.name_switch).to eq "VisitGroup Name"
        end
      end

      context 'Appointment does not belong to VisitGroup' do
        before(:each) { appointment.update_attributes(name: "Appointment Name") }

        it 'should return the name of the Appointment' do
          expect(appointment.name_switch).to eq "Appointment Name"
        end
      end
    end

    describe '#display_name' do
      it 'should be an alias for #name_switch' do
        expect(appointment).to receive(:name_switch).with(no_args).and_return(:name_switch)
        expect(appointment.display_name).to eq :name_switch
      end
    end

    describe '#audit_label' do
      it 'should be an alias for #name_switch' do
        expect(appointment).to receive(:name_switch).with(no_args).and_return(:name_switch)
        expect(appointment.audit_label :audit).to eq :name_switch
      end
    end

    describe '#completed?' do
      context 'completed_at present' do
        it 'should return true' do
          expect(appointment.completed?).to eq true
        end
      end

      context 'completed_at not present' do
        it 'should return false' do
          appointment.update_attributes(completed_at: nil)
          expect(appointment.completed?).to eq false
        end
      end
    end

    describe '#completed_for_core?' do
      context 'completed_at present' do
        context 'Appointment belongs to Core' do
          it 'should return true' do
            expect(appointment.completed_for_core?(core2.id)).to eq(true)
          end
        end

        context 'Appointment does not belong to Core' do
          it 'should return false' do
            expect(appointment.completed_for_core?(core1.id)).to eq(false)
          end
        end
      end

      context 'completed_at absent' do
        before(:each) { appointment.update_attributes(completed_at: nil) }

        context 'Appointment belongs to Core' do
          it 'should return false' do
            expect(appointment.completed_for_core?(core2.id)).to eq(false)
          end
        end

        context 'Appointment does not belong to Core' do
          it 'should return false' do
            expect(appointment.completed_for_core?(core1.id)).to eq(false)
          end
        end
      end
    end
  end
end
