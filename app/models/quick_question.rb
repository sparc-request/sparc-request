class QuickQuestion < ActiveRecord::Base
  audited
  attr_accessible :body, :from, :to
end
