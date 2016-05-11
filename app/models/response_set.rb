class ResponseSet < ActiveRecord::Base
  include Surveyor::Models::ResponseSetMethods
  belongs_to :identity, foreign_key: :user_id
  belongs_to :sub_service_request
end
