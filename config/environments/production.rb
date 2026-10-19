# Copyright © 2011-2022 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# You would need it if you execute ruby outside Rails boot
require "active_support/core_ext/integer/time"

SparcRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  config.public_file_server.enabled = false

  # Compress JavaScripts and CSS
  config.assets.css_compressor = :sass
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true
  config.assets.initialize_on_precompile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # ActiveStorage config
  config.active_storage.service = :local

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile = ["manifest.js"]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Set HTTP/S security headers
  # config.action_dispatch.default_headers = {
  #   'Referrer-Policy' => 'strict-origin-when-cross-origin',
  #   'X-Content-Type-Options' => 'nosniff',
  #   'X-Frame-Options' => 'SAMEORIGIN',
  #   'X-XSS-Protection' => '1; mode=block'
  # }

  # See everything in the log (default is :info)
  # config.log_level = :debug
  config.log_level = :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = { host: ENV.fetch('ROOT_URL') }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production. commented out from rails generated settings.
  # config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

end
