# Copyright © 2011 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.describe 'Directory' do
  ldap_config   ||= YAML.load_file(Rails.root.join('config', 'ldap.yml'))[Rails.env]
  LDAP_UID        ||= ldap_config['ldap_uid']
  LDAP_DEPARTMENT ||= ldap_config['ldap_department']
  LDAP_FIELDS ||= ldap_config['ldap_fields']
  LDAP_UID_FIELD ||= ldap_config['ldap_uid_field'] || LDAP_UID # the unique identifier from LDAP used to generate the uid column in database
  describe 'search' do
    # no tests for search it's the top-level method
  end

  let!(:id1) { create(:identity, ldap_uid: 'mobama@musc.edu', email: 'mo_bama@whitehouse.gov', last_name: 'Obama', first_name: 'Mo') }
  let!(:id2) { create(:identity, ldap_uid: 'georgec@musc.edu', email: 'castanza@uranus.planet', last_name: 'Pluto', first_name: 'Isaplanettoo') }
  let!(:id3) { create(:identity, ldap_uid: 'omally@musc.edu', email: 'omally@musc.edu', last_name: "O'Mally", first_name: 'Shameless') }

  describe 'search_database' do
    it 'should search the ldap uid field' do
      expect(Directory.search_database('mobama')).to eq [ id1 ]
    end

    it 'should search the email field' do
      expect(Directory.search_database('mo_bama')).to eq [ id1 ]
    end

    it 'should search the last_name field' do
      expect(Directory.search_database('Obama')).to eq [ id1 ]
    end

    it 'should search the first_name field' do
      expect(Directory.search_database('Mo')).to eq [ id1 ]
    end

    it 'should search case-independently' do
      expect(Directory.search_database('whitehouse')).to eq [ id1 ]
    end

    it "should search with single quote" do
      expect(Directory.search_database("O'Mally")).to eq [ id3 ]
    end
  end

  describe 'search_ldap' do
    it 'should create new identity from ldap search' do
      identity = Directory.search('leonarjp').first
      expect(identity).not_to eq nil
      expect(identity.ldap_uid).to eq 'jpl6@musc.edu'
      expect(identity.email).to eq 'leonarjp@musc.edu'
      expect(identity.first_name).to eq 'Jason'
      expect(identity.last_name).to eq 'Leonard'

      identity = Directory.search('ash151').first
      expect(identity).not_to eq nil
      expect(identity.ldap_uid).to eq 'ash151@musc.edu'
      expect(identity.email).to eq 'ash@theverybest.com'
      expect(identity.first_name).to eq 'Ash'
      expect(identity.last_name).to eq 'Ketchum'

      identity = Directory.search('Julia').first
      expect(identity).not_to eq nil
      expect(identity.ldap_uid).to eq 'jug2@musc.edu'
      expect(identity.email).to eq 'glennj@musc.edu'
      expect(identity.first_name).to eq 'Julia'
      expect(identity.last_name).to eq 'Glenn'
    end
  end

  describe 'create_or_update_database_from_ldap' do
    it 'should do nothing if ldap_results is nil' do
      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap(nil, Identity.all)
      expect(Identity.count).to eq orig_count
    end

    it 'should do nothing if ldap_results is an empty array' do
      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([], Identity.all)
      expect(Identity.count).to eq orig_count
    end

    it 'should create identities that are not already there' do
      r = {
          "uid" =>       [ 'foo' ],
          "mail" =>      [ 'foo@bar.com' ],
          "givenname" => [ 'Foo' ],
          "sn" =>        [ 'Bar' ],
          "department" => ["Biomed Informatics Core CCts"]}

      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([r], Identity.all)
      expect(Identity.count).to eq orig_count + 1

      id = Identity.find_by_ldap_uid('foo@musc.edu')
      expect(id).not_to eq nil
      expect(id.ldap_uid).to eq 'foo@musc.edu'
      expect(id.email).to eq 'foo@bar.com'
      expect(id.first_name).to eq 'Foo'
      expect(id.last_name).to eq 'Bar'
      expect(id.department).to eq 'Biomed Informatics Core CCts' unless LDAP_DEPARTMENT.blank?
    end

    it 'should update identities that need to be updated' do
      r = {
          "uid" =>       [ 'mobama' ],
          "mail" =>      [ 'bobama@whitehouse.gov' ],
          "givenname" => [ 'Bo' ],
          "sn" =>        [ 'Bama' ]}

      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([r], Identity.all)
      expect(Identity.count).to eq orig_count

      id = Identity.find_by_ldap_uid('mobama@musc.edu')
      expect(id).not_to eq nil
      expect(id.ldap_uid).to eq 'mobama@musc.edu'
      expect(id.email).to eq 'bobama@whitehouse.gov'
      expect(id.first_name).to eq 'Bo'
      expect(id.last_name).to eq 'Bama'
    end
  end
end
