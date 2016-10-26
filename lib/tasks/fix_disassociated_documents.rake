# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
