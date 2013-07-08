class DocumentGrouping < ActiveRecord::Base
  audited

  belongs_to :service_request
  has_many :documents, :dependent => :destroy
  
  attr_accessible :service_request_id
end
