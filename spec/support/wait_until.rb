class WaitUntilTimedOut < StandardError
end

# Wait up to the specified amount of time and return once the block
# returns a truthy (non-false, non-nil) value.
#
# Raises a WaitUntilTimedOut exception if the specified amount of time
# passes without the block returning a truthy value.
#
# If the block returns a truthy value, returns immediately.
#
# This method is similar to Capybara's old wait_until method (which was
# removed in Capybara 2.0).  This method should not be used in normal
# circumstances; use Capybara's matchers instead.  There are some cases
# where a Capybara matcher does not work or is inconvenient; this method
# is supplied for those cases.
#
def wait_until(seconds=10, &block)
  start_time = Time.now
  end_time = start_time + seconds

  loop do
    raise WaitUntilTimedOut, "Timed out" if Time.now > end_time
    result = yield
    return result if result
    sleep 0.01
  end
end

# Like wait_until but keeps going until the block returns without
# raising an exception.
def retry_until(seconds=10, exception=StandardError)
  start_time = Time.now
  end_time = start_time + seconds
  last_exception = nil

  loop do
    if Time.now > end_time then
      if last_exception then
        raise last_exception
      else
        raise WaitUntilTimedOut, "Timed out"
      end
    end

    begin
      result = yield
      return result
    rescue exception => e
      last_exception = e
      sleep 0.01
    end
  end
end

# Wait up to the specified amount of time for all ajax requests on the
# page to complete.
def wait_for_javascript_to_finish(seconds=10)
  wait_until(seconds) { page.evaluate_script('$.active') == 0 }
  # page.should have_content ''
end

