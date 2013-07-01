class Subject < ActiveRecord::Base
  audited

  belongs_to :arm
  has_one :calendar

  attr_accessible :name
  attr_accessible :mrn
  attr_accessible :dob
  attr_accessible :gender
  attr_accessible :ethnicity
  attr_accessible :external_subject_id

  after_create { self.create_calendar }
end
