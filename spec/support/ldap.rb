# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require "#{Rails.root.join("lib/directory")}"

if not USE_LDAP then
  raise "LDAP is not enabled for the test environment.  Please enable it in config/application.yml (Don't worry, the tests won't try to connect to a real LDAP server, because they stub Net::LDAP with test data)."
end

def create_ldap_filter(term)
  fields = [
    Directory::LDAP_UID,
    Directory::LDAP_LAST_NAME,
    Directory::LDAP_FIRST_NAME,
    Directory::LDAP_EMAIL
  ]

  return fields.map {|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
end

RSpec.configure do |config|

  config.before(:each) do
    ldap    = double(port: 636, base: 'ou=people,dc=musc,dc=edu', encryption: :simple_tls)
    results = [
      { "givenname" => ["Ash"], "sn" => ["Ketchum"], "mail" => ["ash@theverybest.com"], "uid" => ["ash151"] },
      { "givenname" => ["Ash"], "sn" => ["Williams"], "mail" => ["ash@s-mart.com"], "uid" => ["ashley"] },
      { "givenname" => ["No"], "sn" => ["Email"], "uid" => ["iamabadldaprecord"] },
      { "givenname" => ['Brian'], "sn" => ['Kelsey'], "uid" => ['bjk7'], "mail" => ['kelsey@musc.edu'] },
      { "givenname" => ['Jason'], "sn" => ['Leonard'], "uid" => ['jpl6@musc.edu'], "mail" => ['leonarjp@musc.edu'] },
      { "givenname" => ['Julia'], "sn" => ['Glenn'], "uid" => ['jug2'], "mail" => ['glennj@musc.edu'] },
    ]

    attributes = ["uid", "sn", "givenname", "mail"]

    allow(ldap).to receive(:search).with(filter: create_ldap_filter('ash151'), attributes: attributes).and_return([results[0]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('bjk7'), attributes: attributes).and_return([results[3]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('leonarjp'), attributes: attributes).and_return([results[4]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('Julia'), attributes: attributes).and_return([results[5]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('ash'), attributes: attributes).and_return([results[0], results[1]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('iamabadldaprecord'), attributes: attributes).and_return([results[2]])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('gary'), attributes: attributes).and_return([])
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('error'), attributes: attributes).and_raise('error')
    allow(ldap).to receive(:search).with(filter: create_ldap_filter('duplicate'), attributes: attributes)

    allow(Net::LDAP).to receive(:new).and_return(ldap)
  end
end
