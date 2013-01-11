class DocumentGrouping < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  has_many :documents, :dependent => :destroy
  
  attr_accessible :service_request_id
end
