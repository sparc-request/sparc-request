desc 'Remove first_draft requests that are over 30 days old'
task :remove_historical_first_draft => :environment do
  Rails.application.eager_load!

  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = false
    end
  end

  end_date = 30.days.ago

  CSV.open("tmp/removed_historical_first_draft_#{end_date.strftime('%m%d%Y')}.csv", "wb") do |csv|

    SubServiceRequest.where("status = ? and updated_at < ?", 'first_draft', end_date).find_each do |ssr|
      service_request = ssr.service_request
      puts "Removing SubServiceRequest ##{ssr.id}"
      csv << [ssr.service_request.protocol_id, ssr.id, ssr.updated_at]
      ssr.destroy!

      service_request.reload

      if service_request.sub_service_requests.empty?
        puts "Removing ServiceRequest ##{service_request.id}"
        csv << [ssr.service_request.protocol_id, ssr.id, ssr.updated_at, service_request.id]
        service_request.destroy!
      end
    end
  end

  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = true
    end
  end

end
