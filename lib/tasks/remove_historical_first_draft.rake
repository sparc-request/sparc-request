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

    count = SubServiceRequest.where("status = ? and updated_at < ?", 'first_draft', end_date).count

    p = ProgressBar.new(count)

    SubServiceRequest.where("status = ? and updated_at < ?", 'first_draft', end_date).find_each do |ssr|
      csv << [ssr.service_request.protocol_id, ssr.id, ssr.updated_at]
      ssr.destroy!
      p.increment! rescue nil
    end
  end
  
  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = true
    end
  end

end
