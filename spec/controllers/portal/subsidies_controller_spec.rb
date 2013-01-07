require 'spec_helper'

describe Portal::SubsidiesController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:study) {
    study = Study.create(FactoryGirl.attributes_for(:protocol));
    study.save!(:validate => false);
    study
  }

  # TODO: assign service_list

  let!(:service_request) {
    FactoryGirl.create(
      :service_request,
      visit_count: 0,
      subject_count: 1,
      protocol_id: study.id)
  }

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
    it 'should set subsidy' do
      # TODO
    end
  end

  describe 'POST create' do
    it 'should set subsidy' do
      post :create, {
        format: :js,
        subsidy: {
          sub_service_request_id: ssr.id,
        },
      }.with_indifferent_access
      assigns(:subsidy).should_not eq nil
      assigns(:subsidy).sub_service_request.should eq ssr
    end

    it 'should set sub_service_request' do
      post :create, {
        format: :js,
        subsidy: {
          sub_service_request_id: ssr.id,
        },
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
    end

    it 'should set pi_contribution to direct_cost_total' do
      SubServiceRequest.any_instance.stub(:direct_cost_total) { 12.34 }
      post :create, {
        format: :js,
        subsidy: {
          sub_service_request_id: ssr.id,
        },
      }.with_indifferent_access
      assigns(:subsidy).pi_contribution.should eq 12 # pi_contribution is an integer
    end
  end

  describe 'POST destroy' do
    it 'should destroy the subsidy' do
      post :destroy, {
        format: :js,
        id: subsidy.id,
      }.with_indifferent_access
      expect { subsidy.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      assigns(:subsidy).should eq nil
    end

    it 'should set service_request and sub_service_request' do
      post :destroy, {
        format: :js,
        id: subsidy.id,
      }.with_indifferent_access
      assigns(:sub_service_request).should eq ssr
      assigns(:service_request).should eq service_request
    end
  end
end

