class Question < ActiveRecord::Base
  attr_accessible :to
  attr_accessible :from
  attr_accessible :body
end
