task send_to_epic: :environment do

  epic_queues = EpicQueue.where(user_change: true, attempted_push: false)

  epic_queues.each do |eq|
    p = Protocol.find(eq.protocol_id)
    p.push_to_epic(EPIC_INTERFACE, nil, nil, true)
  end
end

