# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
desc 'Sync data with CWF'

namespace :cwf_sync do

  task services: :environment do

    puts 'Starting to sync Services with CWF'

    Service.all.each do |service|
      service.update_attribute :updated_at, Time.current
    end

    puts 'Ending to sync Services with CWF'
  end
end
