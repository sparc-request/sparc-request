# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_applications do |t|
      t.string  :name,        null: false
      t.string  :description
      t.string  :uid,         null: false
      t.string  :secret,      null: false

      # Remove `null: false` if you are planning to use grant flows
      # that doesn't require redirect URI to be used during authorization
      # like Client Credentials flow or Resource Owner Password.
      t.text    :redirect_uri
      t.string  :scopes,       null: false, default: ''
      t.boolean :confidential, null: false, default: true
      t.timestamps             null: false
    end

    add_index :oauth_applications, :uid, unique: true

    create_table :oauth_access_grants do |t|
      t.references :resource_owner,  null: false
      t.references :application,     null: false
      t.string   :token,             null: false
      t.integer  :expires_in,        null: false
      t.text     :redirect_uri,      null: false
      t.datetime :created_at,        null: false
      t.datetime :revoked_at
      t.string   :scopes,            null: false, default: ''
    end

    add_index :oauth_access_grants, :token, unique: true
    add_foreign_key(
      :oauth_access_grants,
      :oauth_applications,
      column: :application_id
    )

    create_table :oauth_access_tokens do |t|
      t.references :resource_owner, index: true

      # Remove `null: false` if you are planning to use Password
      # Credentials Grant flow that doesn't require an application.
      t.references :application,    null: false

      # If you use a custom token generator you may need to change this column
      # from string to text, so that it accepts tokens larger than 255
      # characters. More info on custom token generators in:
      # https://github.com/doorkeeper-gem/doorkeeper/tree/v3.0.0.rc1#custom-access-token-generator
      #
      # t.text :token, null: false
      t.string :token, null: false

      t.string   :refresh_token
      t.integer  :expires_in
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string   :scopes

      # The authorization server MAY issue a new refresh token, in which case
      # *the client MUST discard the old refresh token* and replace it with the
      # new refresh token. The authorization server MAY revoke the old
      # refresh token after issuing a new refresh token to the client.
      # @see https://tools.ietf.org/html/rfc6749#section-6
      #
      # Doorkeeper implementation: if there is a `previous_refresh_token` column,
      # refresh tokens will be revoked after a related access token is used.
      # If there is no `previous_refresh_token` column, previous tokens are
      # revoked as soon as a new access token is created.
      #
      # Comment out this line if you want refresh tokens to be instantly
      # revoked after use.
      t.string   :previous_refresh_token, null: false, default: ""
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_foreign_key(
      :oauth_access_tokens,
      :oauth_applications,
      column: :application_id
    )

    create_table :oauth_access_requests do |t|
      t.references  :application
      t.references  :access_token
      t.string      :ip_address,      null: false
      t.string      :status,          null: false
      t.text        :failure_reason
      t.timestamps                    null: false
    end

    add_foreign_key(
      :oauth_access_requests,
      :oauth_applications,
      column: :application_id
    )
    add_foreign_key(
      :oauth_access_requests,
      :oauth_access_tokens,
      column: :access_token_id
    )

    # Uncomment below to ensure a valid reference to the resource owner's table
    add_foreign_key :oauth_access_grants, :identities, column: :resource_owner_id
    add_foreign_key :oauth_access_tokens, :identities, column: :resource_owner_id
  end
end
