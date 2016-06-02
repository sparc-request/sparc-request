require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "PUT #update" do
    context "params[:document] describes a valid update" do
      before(:each) do
        @document = findable_stub(Document) { build_stubbed(:document) }
        allow(@document).to receive(:update_attributes).and_return(true)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        @document_attrs = {}
        xhr :put, :update, id: @document.id, document: @document_attrs
      end

      it "should update document" do
        expect(@document).to have_received(:update_attributes).
          with(@document_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/documents/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:document] describes an invalid update" do
      before(:each) do
        @document = findable_stub(Document) { build_stubbed(:document) }
        allow(@document).to receive(:update_attributes).and_return(false)
        allow(@document).to receive(:errors).and_return("my errors")

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        @document_attrs = {}
        xhr :put, :update, id: @document.id, document: @document_attrs
      end

      it "should attempt to update document" do
        expect(@document).to have_received(:update_attributes).
          with(@document_attrs)
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/documents/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
