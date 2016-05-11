require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "POST #create" do
    context "params[:document] describes a valid Document" do
      before(:each) do
        # stub a savable SubServiceRequest
        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request)
        end
        allow(@sub_service_request).to receive(:save)

        # stub Document#create to return a valid document
        document = build_stubbed(:document)
        allow(Document).to receive(:create).and_return(document)

        logged_in_user = build_stubbed(:identity)
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
        @sub_service_request = findable_stub(SubServiceRequest) do
          build_stubbed(:sub_service_request)
        end
        allow(@sub_service_request).to receive(:save)

        # stub an invalid Document
        document = build_stubbed(:document)
        allow(document).to receive(:valid?).and_return(false)
        allow(document).to receive(:errors).and_return("my errors")
        allow(Document).to receive(:create).and_return(document)

        logged_in_user = build_stubbed(:identity)
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
  end
end
