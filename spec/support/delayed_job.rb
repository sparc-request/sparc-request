# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
module DelayedJobHelpers

  def work_off
    Delayed::Worker.new.work_off
  end
end

RSpec.configure do |config|

  config.include DelayedJobHelpers

  config.before(:each, delay: true) do
    Delayed::Worker.delay_jobs = true
  end

  config.after(:each, delay: true) do
    Delayed::Worker.delay_jobs = false
  end
end
