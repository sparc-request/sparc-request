# Configure action mailer before each request so it knows the right host
# and port to use (the default set in config/environments/test.rb is
# localhost:3000, which is almost certainly wrong).
RSpec.configure do |config|
  config.before :each do
    host = Capybara.current_session.server.host
    port = Capybara.current_session.server.port
    Rails.configuration.action_mailer.default_url_options = "#{host}:#{port}"
    ActionMailer::Base.default_url_options = "#{host}:#{port}"
  end
end
