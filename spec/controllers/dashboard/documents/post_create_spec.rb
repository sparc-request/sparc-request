require "rails_helper"

RSpec.describe Dashboard::DocumentsController do

  describe "POST #create" do

    let(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    context "params[:document] describes a valid Document" do
      
      before(:each) do
        allow(ssr_stub).to receive(:save)
        logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: logged_in_user)
        document  = Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain')
        params = { document: { service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, doc_type: 'Protocol', document: document } }
        xhr :post, :create, params, format: :js
      end 

      it "should create Document" do
        expect(sr_stub.documents.count).to eq(1)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end
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

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/documents/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
