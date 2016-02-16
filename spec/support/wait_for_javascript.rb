module WaitForJavascript

  def wait_for_javascript_to_finish(seconds=15)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests? && finished_all_animations?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active') == 0
  end

  def finished_all_animations?
    page.evaluate_script('$(":animated").length') == 0
  end
end

RSpec.configure do |config|
  config.include WaitForJavascript, type: :feature
end
