class Report < ActiveRecord::Base
  has_attached_file :xlsx
  attr_accessible :xlsx, :report_type
  # attr_accessible :title, :body
end
