namespace :data do
  task fix_historical_epic_queues: :environment do

    puts "Fetching Epic Queue Records with an origin of pi_email_approval since May 2017"

    epic_queue_records = EpicQueueRecord.where(
      origin: 'pi_email_approval',
      created_at: Date.parse('01-05-2017')..Date.today
    )

    puts "#{epic_queue_records.count} Epic Queue Records with an origin of pi_email_approval since May 2017"

    eqr_updated = []

    epic_queue_records.each do |eqr|
      updated_record = eqr.update_attribute(:origin, 'overlord_push')
      eqr_updated << updated_record
    end

    puts "#{eqr_updated.count} Epic Queue Records updated"

    puts "Finding duplicated Epic Queues for deletion..."

    duplicated_eqs = []

    EpicQueueRecord.all.each do |eqr|
      eq = EpicQueue.find_by(protocol_id: eqr.protocol_id, identity_id: eqr.identity_id)
      if !eq.nil?
        deleted_eq = eq.destroy
        duplicated_eqs << deleted_eq
      end
    end

    puts "#{duplicated_eqs.count} duplicated Epic Queues deleted"

    puts "Done"
  end
end
