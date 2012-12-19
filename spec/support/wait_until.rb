class WaitUntilTimedOut < StandardError
end

def wait_until(seconds=10, &block)
  start_time = Time.now
  end_time = start_time + seconds

  loop do
    raise WaitUntilTimedOut, "Timed out" if Time.now > end_time
    result = yield
    return if result
    sleep 0.01
  end
end

def wait_for_javascript_to_finish
  wait_until { page.evaluate_script('$.active') == 0 }
  page.should have_content ''
end

