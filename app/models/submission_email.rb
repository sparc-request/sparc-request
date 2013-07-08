class SubmissionEmail < ActiveRecord::Base
  audited

  belongs_to :organization

  attr_accessible :organization_id
  attr_accessible :email
end
