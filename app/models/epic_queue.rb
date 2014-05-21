class EpicQueue < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :protocol_id
  belongs_to :protocol

  after_create :update_protocol

  def update_protocol
    protocol.update_attributes({:last_epic_push_time => Time.now, :last_epic_push_status => 'complete'})
  end
end
