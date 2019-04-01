# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.2 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Make Active Record use stable #cache_key alongside new #cache_version method.
# This is needed for recyclable cache keys.
# Rails.application.config.active_record.cache_versioning = true

# Use AES-256-GCM authenticated encryption for encrypted cookies.
# Also, embed cookie expiry in signed or encrypted cookies for increased security.
#
# This option is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 5.2.
#
# Existing cookies will be converted on read then written with the new scheme.
# Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = true

# Use AES-256-GCM authenticated encryption as default cipher for encrypting messages
# instead of AES-256-CBC, when use_authenticated_message_encryption is set to true.
# Rails.application.config.active_support.use_authenticated_message_encryption = true

# Add default protection from forgery to ActionController::Base instead of in
# ApplicationController.
# Rails.application.config.action_controller.default_protect_from_forgery = true

# Store boolean values are in sqlite3 databases as 1 and 0 instead of 't' and
# 'f' after migrating old data.
# Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true

# Use SHA-1 instead of MD5 to generate non-sensitive digests, such as the ETag header.
# Rails.application.config.active_support.use_sha1_digests = true
