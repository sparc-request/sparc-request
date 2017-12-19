class EpicQueueManager

  def initialize(protocol, identity, protocol_role)
    @protocol = protocol
    @protocol_role = protocol_role
    @identity = identity
  end

  def create_epic_queue
    if Setting.find_by_key("use_epic").value && withheld_from_epic?(@protocol)
      unless withheld_epic_queue?(@protocol)
        EpicQueue.create(
          protocol_id: @protocol.id,
          identity_id: @identity.id,
          user_change: true
        )
      end
    end
  end


  private

  def withheld_from_epic?(protocol)
    protocol.selected_for_epic && !protocol.last_epic_push_time.nil?
  end

  def withheld_epic_queue?(protocol)
    EpicQueue.where(protocol_id: protocol.id, attempted_push: false).present?
  end
end

