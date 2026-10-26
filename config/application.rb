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

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SparcRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.action_dispatch.default_headers.merge!({'X-Frame-Options' => 'ALLOWALL', 'X-UA-Compatible' => 'IE=edge,chrome=1'})

    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }
    config.time_zone = ENV['time_zone'] || 'Eastern Time (US & Canada)'

    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    # CVE_2022-32224 Fixed releases version change the default YAML deserializer to use YAML.safe_load,
    # which prevents deserialization of possibly dangerous objects. This may introduce backwards compatibility
    # issues with existing data. In order to cope with that situation, the released version also contains
    # two new Active Record configuration options. The configuration options are as follows:
    config.active_record.use_yaml_unsafe_load = true

    # Can also move the following to /initializers/yaml.rb
    # add prefix 'Rails.application'
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::HashWithIndifferentAccess,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      BigDecimal,
      Date,
      Time,
      Symbol
    ]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # see /initializers/obis_setup.rb and application.yml for overriding the :en locale for custom text specific to your institution
    # and, you don't need to override all of the text, only the sets of texts you need customized
    config.i18n.load_path      += Dir[Rails.root.join('config/locales/proper', '*.{rb,yml}').to_s]
    config.i18n.load_path      += Dir[Rails.root.join('config/locales/dashboard', '*.{rb,yml}').to_s]
    config.i18n.load_path      += Dir[Rails.root.join('config/locales/catalog_manager', '*.{rb,yml}').to_s]
    config.i18n.load_path      += Dir[Rails.root.join('config/locales/surveyor', '*.{rb,yml}').to_s]
    config.i18n.default_locale  = :en
    config.i18n.fallbacks       = [:en]

    # The default value for active_record.belongs_to_required_by_default is true
    # for all new Rails 5+ application. For upgraded applications, from Rails 4.x or earlier,
    # the default is effectively false to maintain backward compatibility.
    config.active_record.belongs_to_required_by_default = false


    config.middleware.use PDFKit::Middleware, {
      orientation: 'Portrait',
      margin_left: '1in',
      margin_right: '1in',
      margin_top: '2in',
      margin_bottom: '1in',
      print_media_type: true
    }, :except => [%r[^/dashboard/protocols/\d+\.pdf$]]

    # dartsass-rails: define entry points and suppress dep warnings
    config.dartsass.builds = {
      "application.scss" => "application.css",
      "catalog_manager/application.scss" => "catalog_manager/application.css"
    }

    # Suppress deprecation warnings (@import -> @use/@forward)from 3rd-party deps (bootstrap-sass, etc.)
    # Which requires migrating to Bootstrap 5, which is a major undertaking and not feasible at this time.
    config.dartsass.dart_sass_flags = %w[
      --quiet-deps
      --no-source-map
      --style=compressed
    ]

    ##  Error pages
    config.exceptions_app = routes

    config.to_prepare do
      Doorkeeper::ApplicationsController.layout 'application'
      Doorkeeper::ApplicationController.helper ApplicationHelper
    end
  end
end
