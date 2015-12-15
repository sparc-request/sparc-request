require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j
  build_service_request
  build_project
  build_arms

  before(:each) { arm1.update_attribute(:visit_count, 200) }

  describe 'GET review' do
    shared_examples_for 'always' do
      it 'should set @tab to full calendar' do
        expect(assigns(:tab)).to eq 'calendar'
      end

      it "should set @protocol to the ServiceRequest's Protocol" do
        expect(assigns(:service_request).protocol).to eq service_request.protocol
      end

      it "should set @service_list to the service request's service list" do
        expect(assigns(:service_request).service_list).to eq service_request.service_list
      end

      it 'should reset page for each Arm to 1' do
        expect(assigns(:pages)).to eq(arm1.id => 1, arm2.id => 1)
      end

      it 'should set @review to true' do
        expect(assigns(:review)).to be true
      end

      it 'should set @portal to false' do
        expect(assigns(:portal)).to be false
      end

      it 'should set @thead_class to \'red-provider\'' do
        expect(assigns(:thead_class)).to eq 'red-provider'
      end
    end
    
    context 'with params[:arm_id] and params[:page]' do
      before do
        session[:service_calendar_pages] = { arm1.id.to_s => '1' }
        xhr :get, :review, id: service_request.id, arm_id: arm1.id, page: 2
      end

      it "should change that Arm's service calendar's page to params[:arm_id]" do
        expect(session[:service_calendar_pages][arm1.id.to_s]).to eq '2'
      end

      include_examples 'always'
    end

    context 'with params[:pages]' do
      before do
        xhr :get, :review, { id: service_request.id, pages: { arm1.id.to_s => 42 } }.with_indifferent_access
      end

      it 'should set service_calendar_pages to params[:pages]' do
        expect(session[:service_calendar_pages]).to eq(arm1.id.to_s => '42')
      end

      include_examples 'always'
    end

    context 'without params[:pages]' do
      before do
        arm1.update_attribute(:visit_count, 200)
        xhr :get, :review, { id: service_request.id }.with_indifferent_access
      end

      include_examples 'always'
    end
  end
end
