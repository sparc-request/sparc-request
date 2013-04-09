class Subject < ActiveRecord::Base
  belongs_to :arm
  has_one :calendar
end
