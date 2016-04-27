require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "POST #create" do
    context "params[:document] describes a valid Document" do
      before(:each) do
        # stub a savable SubServiceRequest
        @sub_service_request = build_stubbed(:sub_service_request)
        allow(@sub_service_request).to receive(:save)
        stub_find_sub_service_request(@sub_service_request)

        # stub a Document#create to return a valid document
        document = build_stubbed(:document)
        allow(Document).to receive(:create).and_return(document)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        @document_attrs = { "sub_service_request_id" => @sub_service_request.id.to_s }
        xhr :post, :create, document: @document_attrs
      end

      it "should create Document" do
        expect(Document).to have_received(:create).with(@document_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/documents/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:document] describes an invalid Document" do
      before(:each) do
        @sub_service_request = build_stubbed(:sub_service_request)
        allow(@sub_service_request).to receive(:save)
        stub_find_sub_service_request(@sub_service_request)

        # stub an invalid Document
        document = instance_double(Document, valid?: false, errors: "my errors")
        allow(Document).to receive(:create).and_return(document)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        @document_attrs = { "sub_service_request_id" => @sub_service_request.id.to_s }
        xhr :post, :create, document: @document_attrs
      end

      it "should attempt to create Document" do
        expect(Document).to have_received(:create).with(@document_attrs)
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/documents/create" }
      it { is_expected.to respond_with :ok }
    end

    def stub_find_sub_service_request(obj)
      allow(SubServiceRequest).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
    end
  end
end
