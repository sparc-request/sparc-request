require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request
  build_project
  build_arms
  let!(:arm3) { create(:arm, name: "Arm3", protocol_id: project.id, visit_count: 5, subject_count: 4) }
  let!(:arm4) { create(:arm, name: "Arm4", protocol_id: project.id, visit_count: 10, subject_count: 4) }
  let!(:arm5) { create(:arm, name: "Arm5", protocol_id: project.id, visit_count: 5, subject_count: 4) }

  before(:each) { session[:service_request_id] = service_request.id }

  describe 'GET refresh_service_calendar' do

    context 'params[:portal] set to "true"' do

      it 'should set @thead_class to "ui-widget-header"' do
        xhr :get, :refresh_service_calendar, { id: service_request.id, portal: 'true', format: :js }.with_indifferent_access
        expect(assigns(:thead_class)).to eq 'default_calendar'
      end
    end

    context 'params[:portal] not set to "true" but present' do

      it 'should set @thead_class to "red-provider"' do
        xhr :get, :refresh_service_calendar, { id: service_request.id, portal: 'truthy', format: :js }.with_indifferent_access
        expect(assigns(:thead_class)).to eq 'red-provider'
      end
    end

    context 'params[:portal] absent' do

      it 'should set @thead_class to "red-provider"' do
        xhr :get, :refresh_service_calendar, { id: service_request.id, format: :js }.with_indifferent_access
        expect(assigns(:thead_class)).to eq 'red-provider'
      end
    end

    context 'params[:arm_id] and params[:page] present' do

      before(:each) do
        session[:service_calendar_pages] = { arm1.id.to_s => 1,
                                             arm2.id.to_s => 2,
                                             arm3.id.to_s => 0,
                                             arm4.id.to_s => 2 }
        @scp_keys = session[:service_calendar_pages].keys
        arm2.update_attributes(visit_count: 5)
        xhr :get, :refresh_service_calendar, { id: service_request.id, arm_id: arm1.id, page: 2, format: :js }.with_indifferent_access
      end

      it "should update service_calendar_pages" do
        expect(session[:service_calendar_pages][arm1.id.to_s]).to eq 2
      end

      it "should not add new entries to service_calendar_pages" do
        expect(session[:service_calendar_pages].keys.sort).to eq @scp_keys.sort
      end

      it "should set the page to 1 in @pages for absent Arms" do
        expect(assigns(:pages)[arm5.id]).to eq 1
      end

      it "should wrap page numbers from service_calendar_pages into @pages" do
        expect(assigns(:pages)[arm2.id]).to eq 1
        expect(assigns(:pages)[arm3.id]).to eq 1
      end

      it "should copy entries from service_calendar_pages verbatum if page numbers in range" do
        expect(assigns(:pages)[arm4.id]).to eq 2
      end

      it "should make an entry in @pages for each Arm" do
        expect(assigns(:pages).keys.sort).to eq [arm1, arm2, arm3, arm4, arm5].map(&:id).sort
      end

      it 'should set tab to full calendar' do
        expect(assigns(:tab)).to eq 'calendar'
      end
    end

    context 'params[:pages] present' do

      before(:each) do
        session[:service_calendar_pages] = { '-1' => -1 }
        arm2.update_attributes(visit_count: 5)
        @pages = { arm1.id.to_s => 1,
                   arm2.id.to_s => 2,
                   arm3.id.to_s => 0,
                   arm4.id.to_s => 2 }
        xhr :get, :refresh_service_calendar, { id: service_request.id, pages: @pages, format: :js }.with_indifferent_access
      end

      it 'should set session[:service_calendar_pages] to params[:pages]' do
        expect(session[:service_calendar_pages]).to eq @pages
      end

      it "should set the page to 1 in @pages for absent Arms" do
        expect(assigns(:pages)[arm5.id]).to eq 1
      end

      it "should wrap page numbers from service_calendar_pages into @pages" do
        expect(assigns(:pages)[arm2.id]).to eq 1
        expect(assigns(:pages)[arm3.id]).to eq 1
      end

      it "should copy entries from service_calendar_pages verbatum if page numbers in range" do
        expect(assigns(:pages)[arm4.id]).to eq 2
      end

      it "should make an entry in @pages for each Arm" do
        expect(assigns(:pages).keys.sort).to eq [arm1, arm2, arm3, arm4, arm5].map(&:id).sort
      end

      it 'should set tab to full calendar' do
        expect(assigns(:tab)).to eq 'calendar'
      end
    end

    context 'params[:arm_id], params[:page], and params[:pages] present' do

      before(:each) do
        session[:service_calendar_pages] = { }
        arm2.update_attributes(visit_count: 5)
        @pages = { arm1.id.to_s => 1,
                   arm2.id.to_s => 2,
                   arm3.id.to_s => 0,
                   arm4.id.to_s => 2 }
        xhr :get, :refresh_service_calendar, { id: service_request.id, arm_id: arm1.id, page: 2, pages: @pages, format: :js }.with_indifferent_access
      end

      it "should set service_calendar_pages to params[:pages] with the update applied" do
        expect(session[:service_calendar_pages]).to eq @pages.merge({ arm1.id.to_s => 2 })
      end

      it "should set the page to 1 in @pages for absent Arms" do
        expect(assigns(:pages)[arm5.id]).to eq 1
      end

      it "should wrap page numbers from service_calendar_pages into @pages" do
        expect(assigns(:pages)[arm2.id]).to eq 1
        expect(assigns(:pages)[arm3.id]).to eq 1
      end

      it "should copy entries from service_calendar_pages verbatum if page numbers in range" do
        expect(assigns(:pages)[arm4.id]).to eq 2
      end

      it "should make an entry in @pages for each Arm" do
        expect(assigns(:pages).keys.sort).to eq [arm1, arm2, arm3, arm4, arm5].map(&:id).sort
      end

      it 'should set tab to full calendar' do
        expect(assigns(:tab)).to eq 'calendar'
      end
    end
  end
end
