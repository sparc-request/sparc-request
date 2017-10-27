task send_to_epic: :environment do

  epic_queues = EpicQueue.where(user_change: true, attempted_push: false)

  epic_queues.each do |eq|
    p = Protocol.find(eq.protocol_id)
    p.push_to_epic(EPIC_INTERFACE, 'admin_push', eq.identity_id, true)
    if p.last_epic_push_status == 'complete'
      eq.update_attribute(:attempted_push, true)
    end
  end
end

