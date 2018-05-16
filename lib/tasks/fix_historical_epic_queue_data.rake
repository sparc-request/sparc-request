namespace :data do
  task fix_historical_epic_queue_data: :environment do
    eqrs = EpicQueueRecord.where(created_at: '2017-10-26'.to_date..'2018-04-10'.to_date)

    eqrs.each do |eqr|
      identity = eqr.identity

      unless identity.is_super_user? || identity.is_service_provider? || identity.is_overlord?
        eqr.update_attribute(:origin, 'Protocol Update')
      end
    end
  end
end

