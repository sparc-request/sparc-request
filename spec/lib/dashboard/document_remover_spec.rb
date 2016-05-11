require "rails_helper"

RSpec.describe Dashboard::DocumentRemover do
  context "Document belongs to multiple SubServiceRequests" do
    before(:each) do
      @document = create(:document)
      @sub_service_request1 = create(:sub_service_request_with_organization)
      @sub_service_request1.documents << @document
      @sub_service_request2 = create(:sub_service_request_with_organization)
      @sub_service_request2.documents << @document
    end

    it "should remove Document from the specified SubServiceRequest" do
      Dashboard::DocumentRemover.new(id: @document.id, sub_service_request_id: @sub_service_request1.id)

      expect(@sub_service_request1.reload.documents).to be_empty
    end

    it "should not remove Document from any other SubServiceRequests" do
      Dashboard::DocumentRemover.new(id: @document.id, sub_service_request_id: @sub_service_request1.id)

      expect(@sub_service_request2.reload.documents).not_to be_empty
    end

    it "should not destroy Document" do
      expect do
        Dashboard::DocumentRemover.new(id: @document.id, sub_service_request_id: @sub_service_request1.id)
      end.not_to change { Document.count }
    end
  end

  context "Document belongs to only one SubServiceRequest" do
    before(:each) do
      @document = create(:document)
      @sub_service_request = create(:sub_service_request_with_organization)
      @sub_service_request.documents << @document
    end

    it "should remove Document from SubServiceRequest" do
      Dashboard::DocumentRemover.new(id: @document.id, sub_service_request_id: @sub_service_request.id)

      expect(@sub_service_request.reload.documents).to be_empty
    end

    it "should destroy Document" do
      expect do
        Dashboard::DocumentRemover.new(id: @document.id, sub_service_request_id: @sub_service_request.id)
      end.to change { Document.count }.from(1).to(0)
    end
  end
end
