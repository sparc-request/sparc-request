RSpec.configure do |config|

  config.after(:each, debug_response: true) do
    if request.present?
      Rails.logger.debug "Request params: #{request.params}"
    end
    Rails.logger.debug "Response:\n#{response.body}"
  end
end
