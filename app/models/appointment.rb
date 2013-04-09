class Appointment < ActiveRecord::Base
  belongs_to :calendar
  has_many :procedures
  has_many :visits, :through => :procedures
  
end
