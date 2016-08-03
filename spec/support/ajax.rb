# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
module WaitForAjax

  def wait_for_javascript_to_finish(seconds=15)
    Timeout.timeout(Capybara.timeout) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
