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

require_relative 'boot'

require 'rails/all'
require 'active_storage/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(*Rails.groups)

module SparcRails
  class Application < Rails::Application

    Dotenv::Railtie.load

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_dispatch.default_headers.merge!({'X-Frame-Options' => 'ALLOWALL', 'X-UA-Compatible' => 'IE=edge,chrome=1'})

    config.eager_load = true

    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['time_zone'] || 'Eastern Time (US & Canada)'

    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    # CVE_2022-32224 Fixed releases version change the default YAML deserializer to use YAML.safe_load,
    # which prevents deserialization of possibly dangerous objects. This may introduce backwards compatibility
    # issues with existing data. In order to cope with that situation, the released version also contains
    # two new Active Record configuration options. The configuration options are as follows:
    config.active_record.use_yaml_unsafe_load = true
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time]

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

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.middleware.use PDFKit::Middleware, {
      orientation: 'Portrait',
      margin_left: '1in',
      margin_right: '1in',
      margin_top: '2in',
      margin_bottom: '1in',
      print_media_type: true
    }, :except => [%r[^/dashboard/protocols/\d+\.pdf$]]
      
    ##  Error pages
    config.exceptions_app = self.routes

    config.to_prepare do
      Doorkeeper::ApplicationsController.layout 'application'
      Doorkeeper::ApplicationController.helper ApplicationHelper
    end
  end
end
