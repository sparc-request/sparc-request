class CreateJoinTableDocumentsSubServiceRequests < ActiveRecord::Migration

  def seed_docs_to_join_and_delete_duplicates
    DocumentGrouping.find_each do |dg|
      next if dg.documents.empty?
      # get unique documents in grouping based on created_at date
      clean_group = dg.documents.inject([]) { |result,doc| result << doc unless result.collect{|doc_b| doc_b.created_at}.include?(doc.created_at); result }
      clean_group.each do |doc|
        # get ssr_ids of all documents of a particular created_date
        ssr_ids = Document.where(created_at: doc.created_at, document_grouping_id: dg.id).map { |repeated_doc| repeated_doc.sub_service_request_id}
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
      # set document's service_request_id to doc's document_grouping's service_request_id
      doc.service_request_id = DocumentGrouping.find_by_id(doc.document_grouping_id).service_request_id
      doc.save
    end
  end

  def recreate_document_groupings
    Document.find_each do |doc|
      # create document_grouping, set dg's sr_id to doc's sr_id, set doc's dg_id to new dg's id
      dg = DocumentGrouping.create(service_request_id: doc.service_request_id)
      doc.document_grouping_id = dg.id
      doc.save
    end
  end

  def recreate_duplicates
    Document.find_each do |doc|
      doc.sub_service_requests.each do |ssr|
        # copy existing documents for each doc-ssr relation and set ssr_id of copied docs to each doc-ssr relation's ssr_id
        next if ssr.id == doc.sub_service_request_id
        newDoc = doc.clone
        newDoc.sub_service_request_id = ssr.id
        newDoc.save
      end
    end
  end

  def reseed_ssr_ids
    Document.find_each do |doc|
      # set doc's ssr_id to first id of first ssr in doc-ssr relation
      doc.sub_service_request_id = doc.sub_service_requests.first.id
      doc.save
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
    # create_join_table :sub_service_requests, :documents, table_name: :sub_service_requests_documents
    create_table :sub_service_requests_documents, id: false do |t|
      t.belongs_to :sub_service_request
      t.belongs_to :document
    end
    seed_docs_to_join_and_delete_duplicates
    remove_column :documents, :sub_service_request_id, :integer
    add_column :documents, :service_request_id, :integer
    seed_doc_sr_relation
    remove_column :documents, :document_grouping_id, :integer
    drop_table :document_grouping
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
    recreate_document_groupings
    remove_column :documents, :service_request_id, :integer
    add_column :documents, :sub_service_request_id, :integer
    reseed_ssr_ids
    recreate_duplicates
    drop_table :sub_service_requests_documents
  end
end
