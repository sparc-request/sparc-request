require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "GET #new" do
    context "params[:one_time_fee] present" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:candidate_pppv_services).
          and_return("candidate pppv services")

        allow(LineItem).to receive(:new).and_return("my new LineItem")

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :new, sub_service_request_id: @sub_service_request.id,
          schedule_tab: "my schedule tab", one_time_fee: "yep"
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should set @schedule_tab from params[:schedule_tab]" do
        expect(assigns(:schedule_tab)).to eq("my schedule tab")
      end

      it "should assign @line_item to a new line_item" do
        expect(assigns(:line_item)).to eq("my new LineItem")
      end

      it "should assign @header_text" do
        expect(assigns(:header_text)).not_to be_nil
      end

      it { is_expected.to render_template "dashboard/line_items/new" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:one_time_fee] absent" do
      before(:each) do
        @service_request = build_stubbed(:service_request)
        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        allow(@sub_service_request).to receive(:candidate_pppv_services).
          and_return("candidate pppv services")

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :new, sub_service_request_id: @sub_service_request.id,
          schedule_tab: "my schedule tab", page_hash: "my page hash"
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should set @schedule_tab from params[:schedule_tab]" do
        expect(assigns(:schedule_tab)).to eq("my schedule tab")
      end

      it "should set @services to PPPV candidate Services of SubServiceRequest" do
        expect(assigns(:services)).to eq("candidate pppv services")
      end

      it "should set @page_hash from params[:page_hash]" do
        expect(assigns(:page_hash)).to eq("my page hash")
      end

      it { is_expected.to render_template "dashboard/line_items/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
