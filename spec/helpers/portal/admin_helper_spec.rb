require 'spec_helper'

describe Portal::AdminHelper do
  include Portal::AdminHelper

  let(:service_request) { ServiceRequest.new(:submitted_at => '10/10/2011')}
  let(:sub_service_request) { RelatedServiceRequest.new(:sub_service_request_id => 'ABC')}

  context :display_document_type do
    let(:type) { 'hipaa' }

    it 'should return the display value given a document type' do
      helper.display_document_type(type).should eq('HIPAA')
    end
  end
end
