class Report < ActiveRecord::Base
  belongs_to :sub_service_request

  has_attached_file :xlsx
  attr_accessible :xlsx, :report_type
  # attr_accessible :title, :body
end
