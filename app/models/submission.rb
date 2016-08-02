class Submission < ActiveRecord::Base
  belongs_to :service
  belongs_to :identity
end
