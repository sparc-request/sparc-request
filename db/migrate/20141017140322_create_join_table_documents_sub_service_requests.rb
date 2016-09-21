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

class CreateJoinTableDocumentsSubServiceRequests < ActiveRecord::Migration

  class SubServiceRequest < ActiveRecord::Base
    has_and_belongs_to_many :documents
    attr_accessible :documents
  end

  class Document < ActiveRecord::Base
    has_and_belongs_to_many :sub_service_requests
    belongs_to :service_request
    attr_accessible :sub_service_requests
    attr_accessible :service_request_id
  end

  class ServiceRequest < ActiveRecord::Base
    has_many :documents, :dependent => :destroy
  end

  def clean_grouping grouping
    used_created_dates = []
    grouping.documents.each do |doc|
      next if (used_created_dates.include? doc.created_at or used_created_dates.include? doc.created_at-1 or used_created_dates.include? doc.created_at+1)#already dealt with this document
      used_created_dates << doc.created_at # store unique dates from grouping based on created_at date
      ssr_ids = []
      ssr_ids << doc.sub_service_request_id
      # get ssr_ids of all documents of a particular created_date
      repeated_docs = grouping.documents.where("created_at >= :startTime AND created_at <= :endTime", {startTime: doc.created_at-1, endTime: doc.created_at+1})
      repeated_docs.each do |copy|
        next if copy.id == doc.id
        doc_change = (doc.document_file_name != copy.document_file_name or doc.document_file_size != copy.document_file_size)
        type_change = (doc.doc_type != copy.doc_type or (doc.doc_type == 'other' ? doc.doc_type_other != copy.doc_type_other : false))
        if doc_change or type_change
          #copy is different from unique, keep copy and seed to join.
          ssr = SubServiceRequest.find(copy.sub_service_request_id)
          ssr.documents << copy
          ssr.save
        else
          #copy is same as unique, append copy's ssr_id and destroy it
          ssr_ids << copy.sub_service_request_id
          copy.destroy
        end
      end
      ssr_ids.each do |ssr_id|
        ssr = SubServiceRequest.find(ssr_id)
        #create associations in join table by adding the doc to the SSR's list of documents
        ssr.documents << doc
        ssr.save
      end
    end
  end

  def seed_docs_to_join_and_delete_duplicates
    Document.where(document_grouping_id: nil).each do |doc|
      ssr = SubServiceRequest.find(doc.sub_service_request_id)
      ssr.documents << doc
      ssr.save
    end
    DocumentGrouping.find_each do |dg|
      next if dg.documents.empty?
      if dg.documents.size == 1
        doc = dg.documents.first
        ssr = SubServiceRequest.find(doc.sub_service_request_id)
        ssr.documents << doc
        ssr.save
      else
        clean_grouping dg
      end
    end
  end

  def seed_doc_sr_relation
    Document.find_each do |doc|
      # set document's service_request_id to doc's SubServiceRequest's service_request_id
      doc.service_request_id = SubServiceRequest.find(doc.sub_service_request_id).service_request_id
      doc.save
    end
  end

  def up
    create_table :documents_sub_service_requests, id: false do |t|
      t.belongs_to :document
      t.belongs_to :sub_service_request
    end
    add_column :documents, :service_request_id, :integer
    seed_doc_sr_relation
    seed_docs_to_join_and_delete_duplicates
    remove_column :documents, :sub_service_request_id
    remove_column :documents, :document_grouping_id
    drop_table :document_groupings
    # Remove Document_grouping model
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
