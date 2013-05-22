class Subject < ActiveRecord::Base
  audited

  belongs_to :arm
  has_one :calendar

  attr_accessible :name

  after_create { self.create_calendar }
end
