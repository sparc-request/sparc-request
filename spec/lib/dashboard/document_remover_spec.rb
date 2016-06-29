require "rails_helper"

RSpec.describe Dashboard::DocumentRemover do
  before(:each) do
    @protocol             = create(:unarchived_study_without_validations)
    @document             = create(:document, protocol: @protocol)
    @sub_service_request1 = create(:sub_service_request_with_organization)
    @sub_service_request2 = create(:sub_service_request_with_organization)

    @protocol.documents             << @document
    @sub_service_request1.documents << @document
    @sub_service_request2.documents << @document

    Dashboard::DocumentRemover.new(@document.id)
  end

  it "should remove Document from the specified Protocol" do
    expect(@protocol.reload.documents).to be_empty
  end

  it "should remove all associations to SubServiceRequests" do
    expect(@sub_service_request1.reload.documents).to be_empty
    expect(@sub_service_request2.reload.documents).to be_empty
  end
end
