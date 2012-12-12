class Document < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  include Paperclip::Glue
  belongs_to :sub_service_request
  has_one :organization, :through => :sub_service_request
  belongs_to :document_grouping
  has_attached_file :document #, :preserve_files => true

  attr_accessible :document
  attr_accessible :doc_type
  attr_accessible :document_grouping_id
  attr_accessible :sub_service_request_id
end
