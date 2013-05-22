class Question < ActiveRecord::Base
  audited

  attr_accessible :to
  attr_accessible :from
  attr_accessible :body
end
