def get_alert_window
  # TODO: not yet supported by poltergeist
  if Capybara.javascript_driver == :poltergeist then
    warn "WARNING: called accept_alert with poltergeist as driver"
    return
  end

  prompt = page.driver.browser.switch_to.alert
  yield prompt if block_given?
end

