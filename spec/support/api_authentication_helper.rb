module ApiAuthenticationHelper

  def http_login(username=REMOTE_SERVICE_NOTIFIER_USERNAME, password=REMOTE_SERVICE_NOTIFIER_PASSWORD)
    @env ||= {}

    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
