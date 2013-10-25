require 'spec_helper'

describe Portal::VisitsController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service) {
    service = FactoryGirl.create(
        :service,
        organization: core,
        pricing_map_count: 1)
    service.pricing_maps[0].display_date = Date.today
    service
  }

  let!(:project) { FactoryGirl.create_without_validation(:project) }
  let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: project.id) }
  let!(:arm) { FactoryGirl.create(:arm, protocol_id: project.id, visit_count: 0, subject_count: 1) }

  let!(:ssr) {
    FactoryGirl.create(
        :sub_service_request,
        service_request_id: service_request.id,
        organization_id: core.id)
  }

  let!(:subsidy) {
    FactoryGirl.create(
        :subsidy,
        sub_service_request_id: ssr.id)
  }

  describe 'POST update_from_fulfillment' do
    # TODO
  end

  describe 'destroy' do
    context 'we have one line item' do
      let!(:line_item) {
        FactoryGirl.create(
            :line_item,
            service_id: service.id,
            service_request_id: service_request.id,
            sub_service_request_id: ssr.id)
      }

      let!(:visit) {
        arm.update_attributes(visit_count: 1)
        arm.create_line_items_visit(line_item)
        visit = arm.visits[0]
      }

      it 'should set instance variables' do
        post :destroy, {
          format: :js,
          id: visit.id,
        }.with_indifferent_access
        assigns(:visit).should eq visit
        assigns(:sub_service_request).should eq ssr
        assigns(:service_request).should eq service_request
        assigns(:subsidy).should eq subsidy
        assigns(:candidate_per_patient_per_visit).should eq [ service ]
      end

      it 'should destroy the visit' do
        post :destroy, {
          format: :js,
          id: visit.id,
        }.with_indifferent_access
        expect { visit.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'should fix the pi contribution on the subsidy' do
        Subsidy.any_instance.stub(:fix_pi_contribution) {
          subsidy.update_attributes(pi_contribution: 12)
        }

        post :destroy, {
          format: :js,
          id: visit.id,
        }.with_indifferent_access
        subsidy.reload
        subsidy.pi_contribution.should eq 12
      end
    end

    context 'we have multiple line items' do
      let!(:line_item1) {
        FactoryGirl.create(
            :line_item,
            service_id: service.id,
            service_request_id: service_request.id,
            sub_service_request_id: ssr.id)
      }

      let!(:line_item2) {
        FactoryGirl.create(
            :line_item,
            service_id: service.id,
            service_request_id: service_request.id,
            sub_service_request_id: ssr.id)
      }

      let!(:line_item3) {
        FactoryGirl.create(
            :line_item,
            service_id: service.id,
            service_request_id: service_request.id,
            sub_service_request_id: ssr.id)
      }

      it 'should destroy all the other visits at the same position' do
        arm.update_attributes(visit_count: 10)
        arm.create_line_items_visit(line_item1)
        arm.create_line_items_visit(line_item2)
        arm.create_line_items_visit(line_item3)

        visit = arm.visits[0]
        visits = arm.visit_groups.find_by_position(visit.position).visits

        post :destroy, {
          format: :js,
          id: visit.id,
        }.with_indifferent_access

        # Reloading deleted visits should result in an exception
        visits.each do |v|
          expect { v.reload }.to raise_exception(ActiveRecord::RecordNotFound)
          expect { v.reload }.to raise_exception(ActiveRecord::RecordNotFound)
          expect { v.reload }.to raise_exception(ActiveRecord::RecordNotFound)
        end

        LineItemsVisit.for(arm, line_item1).visits.count.should eq 9
        LineItemsVisit.for(arm, line_item2).visits.count.should eq 9
        LineItemsVisit.for(arm, line_item3).visits.count.should eq 9
      end

      it 'should update visit count' do
        arm.update_attributes(visit_count: 10)
        arm.create_line_items_visit(line_item1)
        arm.create_line_items_visit(line_item2)
        arm.create_line_items_visit(line_item3)

        visit = arm.visits[0]
        visits = arm.visit_groups.find_by_position(visit.position).visits

        post :destroy, {
          format: :js,
          id: visit.id,
        }.with_indifferent_access

        arm.reload
        arm.visit_count.should eq 9
      end
    end
  end
end

