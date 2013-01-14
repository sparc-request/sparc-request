require 'ostruct'
require 'spec_helper'

describe 'Directory' do
  describe 'search' do
    # no tests for search it's the top-level method
  end

  let!(:id1) { FactoryGirl.create(:identity, ldap_uid: 'mobama@musc.edu', email: 'mo_bama@whitehouse.gov', last_name: 'Obama', first_name: 'Mo') }
  let!(:id2) { FactoryGirl.create(:identity, ldap_uid: 'georgec@musc.edu', email: 'castanza@uranus.planet', last_name: 'Pluto', first_name: 'Isaplanettoo') }

  describe 'search_database' do
    it 'should search the ldap uid field' do
      Directory.search_database('mobama').should eq [ id1 ]
    end

    it 'should search the email field' do
      Directory.search_database('mo_bama').should eq [ id1 ]
    end

    it 'should search the last_name field' do
      Directory.search_database('Obama').should eq [ id1 ]
    end

    it 'should search the first_name field' do
      Directory.search_database('Mo').should eq [ id1 ]
    end

    it 'should search case-independently' do
      Directory.search_database('WhItEhOuSe').should eq [ id1 ]
    end
  end

  describe 'search_ldap' do
    # TODO: for now, no tests for search_database; it talks to LDAP
    # directly
  end

  describe 'create_or_update_database_from_ldap' do
    it 'should do nothing if ldap_results is nil' do
      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap(nil, Identity.all)
      Identity.count.should eq orig_count
    end

    it 'should do nothing if ldap_results is an empty array' do
      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([], Identity.all)
      Identity.count.should eq orig_count
    end

    it 'should create identities that are not already there' do
      r = OpenStruct.new(
          uid:       [ 'foo' ],
          mail:      [ 'foo@bar.com' ],
          givenname: [ 'Foo' ],
          sn:        [ 'Bar' ])

      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([r], Identity.all)
      Identity.count.should eq orig_count + 1

      id = Identity.find_by_ldap_uid('foo@musc.edu')
      id.should_not eq nil
      id.ldap_uid.should eq 'foo@musc.edu'
      id.email.should eq 'foo@bar.com'
      id.first_name.should eq 'Foo'
      id.last_name.should eq 'Bar'
    end

    it 'should update identities that need to be updated' do
      r = OpenStruct.new(
          uid:       [ 'mobama' ],
          mail:      [ 'bobama@whitehouse.gov' ],
          givenname: [ 'Bo' ],
          sn:        [ 'Bama' ])

      orig_count = Identity.count
      Directory.create_or_update_database_from_ldap([r], Identity.all)
      Identity.count.should eq orig_count

      id = Identity.find_by_ldap_uid('mobama@musc.edu')
      id.should_not eq nil
      id.ldap_uid.should eq 'mobama@musc.edu'
      id.email.should eq 'bobama@whitehouse.gov'
      id.first_name.should eq 'Bo'
      id.last_name.should eq 'Bama'
    end
  end
end

