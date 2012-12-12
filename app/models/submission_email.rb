class SubmissionEmail < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization

  attr_accessible :organization_id
  attr_accessible :email
end

class SubmissionEmail::ObisEntitySerializer
  def as_json(submission_email, options = nil)
    return submission_email.email
  end

  def update_from_json(submission_email, h, options = nil)
    submission_email.update_attributes!(
        :email => h)
  end
end

class SubmissionEmail
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

