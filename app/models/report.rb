class Report < ActiveRecord::Base
  audited
  belongs_to :sub_service_request

  has_attached_file :xlsx
  attr_accessible :xlsx, :report_type
  # attr_accessible :title, :body
  

  ### audit reporting methods ###
  
  def audit_excluded_fields
    {'create' => ['sub_service_request_id', 'xlsx_file_name', 'xlsx_content_type', 'xlsx_file_size', 'xlsx_updated_at']}
  end

  ### end audit reporting methods ###
end
