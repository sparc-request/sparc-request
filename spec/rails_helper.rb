# Copyright © 2011-2019 MUSC Foundation for Research Development
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

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'spec_helper'
require 'site_prism'
require 'tilt/coffee'
require 'tilt/sass'
require 'rails-controller-testing'

RSpec.configure do |config|

  # Manually including ::Rails::Controller::Testing::*
  # until we upgrade RSpec to 3.5.0
  [:controller, :view].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end
  config.include ::Rails::Controller::Testing::TestProcess, js: true
  config.include ::Rails::Controller::Testing::TemplateAssertions, js: true
  config.include ::Rails::Controller::Testing::Integration, js: true

  # TODO mark spec types explicitly
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.after(:each) do
    # wait on all the push to epic calls to finish
    # TODO: ideally we should call Thread#join for all the 'push to
    # epic' threads
    Protocol.all.each do |protocol|
      while protocol.push_to_epic_in_progress? do
        sleep 0.1
        protocol.reload
      end
    end
  end
end

# There is a bug with Shoulda-Matchers that causes the
# serialize matcher to throw the following error:
#
# NoMethodError:
#   undefined method `cast_type' for #<ActiveRecord::ConnectionAdapters::MySQL::Column:0x007f8dcc21d778>
#
# See https://github.com/thoughtbot/shoulda-matchers/issues/913
module Shoulda
  module Matchers
    RailsShim.class_eval do
      def self.serialized_attributes_for(model)
        if defined?(::ActiveRecord::Type::Serialized)
          # Rails 5+
          model.columns.select do |column|
            model.type_for_attribute(column.name).is_a?(::ActiveRecord::Type::Serialized)
          end.inject({}) do |hash, column|
            hash[column.name.to_s] = model.type_for_attribute(column.name).coder
            hash
          end
        else
          model.serialized_attributes
        end
      end
    end
  end
end
