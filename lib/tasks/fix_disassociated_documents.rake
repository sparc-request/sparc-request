# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
desc "Fix disassociated documents"
task :fix_disassociated_documents => :environment do
  class DocumentSubServiceRequest < ActiveRecord::Base
    self.table_name = "documents_sub_service_requests"
    belongs_to :document
    belongs_to :sub_service_request
  end

  fixed_count = 0
  unfixed_count = 0
  DocumentSubServiceRequest.all.each do |dssr|
    doc = dssr.document
    ssr = dssr.sub_service_request

    if doc.service_request_id == ssr.service_request_id
      unfixed_count += 1
      next
    end

    fixed_count += 1


    if doc.sub_service_requests.count == 1
      puts "Updating existing document #{doc.id} with new service request id #{ssr.service_request_id} for sub service request #{ssr.id}"
      doc.update_attributes(service_request_id: ssr.service_request_id)
      puts ""
    else
      puts "Existing document #{doc.id} belongs to multiple sub service request, creating a new document, associating new document with the sub service request #{ssr.id}, deleting old document association for this sub service request #{ssr.id}"
      new_document = Document.create :document => doc.document, :doc_type => doc.doc_type, :doc_type_other => doc.doc_type_other, :service_request_id => ssr.service_request_id
      ssr.documents << new_document
      ssr.documents.delete doc
      puts ""
    end
  end

  puts "#{fixed_count} documents would be properly reassociated, #{unfixed_count} would remain untouched"
end
