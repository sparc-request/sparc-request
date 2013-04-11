class Subject < ActiveRecord::Base
  belongs_to :arm
  has_one :calendar

  after_create { self.create_calendar }
end
