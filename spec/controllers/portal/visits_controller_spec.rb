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

  let!(:service_request) { FactoryGirl.create(:service_request) }
  let!(:arm) { FactoryGirl.create(:arm, service_request_id: service_request.id, visit_count: 0, subject_count: 1) }

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

      let!(:visit_grouping) {
        FactoryGirl.create(
            :visit_grouping,
            arm_id: arm.id,
            line_item_id: line_item.id,
            subject_count: 1)
      }

      let!(:visit) {
        # TODO: use ServiceRequest#add_visit ?
        arm.update_attributes(visit_count: 1)
        FactoryGirl.create(
            :visit,
            visit_grouping_id: visit_grouping.id,
            research_billing_qty: 5)
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

      let!(:visit_grouping1) {
        FactoryGirl.create(
            :visit_grouping,
            arm_id: arm.id,
            line_item_id: line_item1.id,
            subject_count: 1)
      }

      let!(:visit_grouping2) {
        FactoryGirl.create(
            :visit_grouping,
            arm_id: arm.id,
            line_item_id: line_item2.id,
            subject_count: 1)
      }

      let!(:visit_grouping3) {
        FactoryGirl.create(
            :visit_grouping,
            arm_id: arm.id,
            line_item_id: line_item3.id,
            subject_count: 1)
      }

      it 'should destroy all the other visits at the same position' do
        vg1_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping1.id)
        vg2_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping2.id)
        vg3_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping3.id)
        arm.update_attributes(visit_count: 10)

        post :destroy, {
          format: :js,
          id: vg1_visits[4].id,
        }.with_indifferent_access

        expect { vg1_visits[4].reload }.to raise_exception(ActiveRecord::RecordNotFound)
        expect { vg2_visits[4].reload }.to raise_exception(ActiveRecord::RecordNotFound)
        expect { vg3_visits[4].reload }.to raise_exception(ActiveRecord::RecordNotFound)

        visit_grouping1.reload
        visit_grouping2.reload
        visit_grouping3.reload

        visit_grouping1.visits.count.should eq 9
        visit_grouping2.visits.count.should eq 9
        visit_grouping3.visits.count.should eq 9
      end

      it 'should update visit count' do
        vg1_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping1.id)
        vg2_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping2.id)
        vg3_visits = Visit.bulk_create(10, visit_grouping_id: visit_grouping3.id)
        arm.update_attributes(visit_count: 10)

        post :destroy, {
          format: :js,
          id: vg1_visits[4].id,
        }.with_indifferent_access

        arm.reload
        arm.visit_count.should eq 9
      end
    end
  end
end

