require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "POST #create" do
    context "params[:line_item][:service_id] blank" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = build_stubbed(:sub_service_request)
        allow(@sub_service_request).to receive(:service_request).and_return(@service_request)
        allow(@sub_service_request).to receive(:candidate_pppv_services).and_return("candidate pppv services")
        stub_find_sub_service_request(@sub_service_request)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        xhr :post, :create, line_item: { sub_service_request_id: @sub_service_request.id }
      end

      it "should set @sub_service_request from params[:line_item][:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should add an error message to SubServiceRequest for Service" do
        expect(assigns(:errors).full_messages).to eq(["Service must be selected"])
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:line_item][:service_id] present but params[:line_item] still describes an invalid LineItem" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = instance_double(SubServiceRequest,
          id: 1,
          service_request: @service_request,
          errors: "my errors")
        stub_find_sub_service_request(@sub_service_request)

        # params[:line_item] does not describe valid LineItem
        allow(@sub_service_request).to receive(:create_line_item).and_return(false)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        xhr :post, :create, line_item: { service_id: "not blank", sub_service_request_id: @sub_service_request.id }
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:line_item] describes a valid LineItem" do
      before(:each) do
        @service_request = build_stubbed(:service_request)

        @sub_service_request = instance_double(SubServiceRequest,
          id: 1,
          service_request: @service_request,
          errors: "my errors")
        stub_find_sub_service_request(@sub_service_request)

        # params[:line_item] does not describe valid LineItem
        allow(@sub_service_request).to receive(:create_line_item).and_return(true)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        xhr :post, :create, line_item: { service_id: "not blank", sub_service_request_id: @sub_service_request.id }
      end

      it "should set @sub_service_request from params[:sub_service_request_id]" do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it "should set @service_request from params[:sub_service_request_id]" do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/line_items/create" }
      it { is_expected.to respond_with :ok }
    end

    def stub_find_sub_service_request(ssr_stub)
      allow(SubServiceRequest).to receive(:find).
        with(ssr_stub.id.to_s).
        and_return(ssr_stub)
    end
  end
end
