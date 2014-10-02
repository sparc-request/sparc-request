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

  def seed_docs_to_join_and_delete_duplicates
    Document.where(document_grouping_id: nil).each do |doc|
      doc.sub_service_requests << SubServiceRequest.find(doc.sub_service_request_id)
      doc.save
    end
    DocumentGrouping.find_each do |dg|
      next if dg.documents.empty?
      # get unique documents in grouping based on created_at date
      clean_group = dg.documents.inject([]) { |result,doc| result << doc unless result.collect{|doc_b| doc_b.created_at}.include?(doc.created_at); result }
      clean_group.each do |doc|
        # get ssr_ids of all documents of a particular created_date
        ssr_ids = Document.where(created_at: doc.created_at, document_file_size: doc.document_file_size, document_grouping_id: dg.id).map { |repeated_doc| repeated_doc.sub_service_request_id}
        ssr_ids.each do |ssr_id|
          ssr = SubServiceRequest.find_by_id(ssr_id)
          #create associations in join table by adding the doc to the SSR's list of documents
          ssr.documents << doc
          ssr.save
        end
        Document.where(created_at: doc.created_at, document_grouping_id: dg.id).each{ |repeated_doc| repeated_doc.delete unless doc.id == repeated_doc.id}
      end
    end
  end

  def seed_doc_sr_relation
    Document.find_each do |doc|
      # set document's service_request_id to doc's SubServiceRequest's service_request_id
      doc.service_request_id = SubServiceRequest.find(doc.sub_service_request_id).service_request_id
      doc.save
      # Document.find(doc.id).update_attributes(:service_request_id => SubServiceRequest.find(doc.sub_service_request_id).service_request_id)
    end
  end

  def reseed_ssr_ids_and_recreate_duplicates
    # recreate doc_groupings, reseed ssr_ids, and recreate duplicates
    Document.find_each do |doc|
      next if doc.document_grouping_id or doc.sub_service_requests.empty?
      # create document_grouping, set dg's sr_id to doc's sr_id, set doc's dg_id to new dg's id
      group = DocumentGrouping.create(service_request_id: doc.service_request_id)
      doc.document_grouping_id = group.id
      # set doc's ssr_id to first id of first ssr in doc-ssr relation
      doc.sub_service_request_id = doc.sub_service_requests.first.id
      doc.save
      doc.sub_service_requests.each do |ssr|
        # copy existing documents for each doc-ssr relation and set ssr_id of copied docs to each doc-ssr relation's ssr_id
        next if doc.sub_service_request_id == ssr.id
        newDoc = doc.dup
        newDoc.document_grouping_id = group.id
        newDoc.sub_service_request_id = ssr.id
        newDoc.save
      end
    end
  end

  def up
    # Change relations in models to:
      # SSR has_and_belongs_to_many :documents
      # Document has_and_belongs_to_many :sub_service_requests
      # SR has_many :documents, :dependent => :destroy
      # Document belongs_to :service_request
    # Remove from document.rb: attr_accessible :document_grouping_id
    # Remove from document.rb: attr_accessible :sub_service_request_id
    # Add to document.rb: attr_accessible :sub_service_requests
    # Add to sub_service_request.rb: attr_accessible :documents
    # Remove relation: SR has_many :document_groupings, :dependent => :destroy
    # Remove relation: Document has_one :organization, :through => :sub_service_request
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
    # Change relations in models to:
      # SSR has_many :documents, :dependent => :destroy
      # Document belongs_to :sub_service_request
      # SR has_many :documents, :through => :sub_service_requests
      # SR has_many :document_groupings, :dependent => :destroy
      # Document belongs_to :document_grouping
      # Document has_one :organization, :through => :sub_service_request
    # Add to document.rb: attr_accessible :document_grouping_id
    # Add to document.rb: attr_accessible :sub_service_request_id
    # Remove from document.rb: attr_accessible :sub_service_requests
    # Remove from sub_service_request.rb: attr_accessible :documents
    # Create Document_grouping model:
      # class DocumentGrouping < ActiveRecord::Base
      #   audited
      #   belongs_to :service_request
      #   has_many :documents, :dependent => :destroy
      #   attr_accessible :service_request_id
      # end
    create_table :document_groupings do |t|
      t.belongs_to :service_request
      t.timestamps
    end
    add_column :documents, :document_grouping_id, :integer
    add_column :documents, :sub_service_request_id, :integer
    reseed_ssr_ids_and_recreate_duplicates
    remove_column :documents, :service_request_id
    drop_table :documents_sub_service_requests
  end
end
