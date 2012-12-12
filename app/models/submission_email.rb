class SubmissionEmail < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization

  attr_accessible :organization_id
  attr_accessible :email
end
