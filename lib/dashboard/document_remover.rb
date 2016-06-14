module Dashboard
  class DocumentRemover
    def initialize(params)
      sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      document = Document.find(params[:id])

      # remove Document from SubServiceRequest
      sub_service_request.documents.delete(document)
      sub_service_request.save # necessary?

      # if Document has been orphaned, delete it
      document.destroy if document.sub_service_requests.empty?
    end
  end
end
