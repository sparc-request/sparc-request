describe 'Directory' do
  describe 'search' do
    # no tests for search it's the top-level method
  end

  let!(:id1) { FactoryGirl.create(ldap_uid: 'mobama', email: 'mo_bama@whitehouse.gov', last_name: 'Obama', first_name: 'Mo' }

  describe 'search_database' do
    it 'should search the ldap uid field' do
      Directory.search_database('mo_bama').should eq id1
    end

    it 'should search the email field' do
      Directory.search_database('mo_bama').should eq id1
    end

    it 'should search the last_name field' do
      Directory.search('Obama').should eq id1
    end

    it 'should search the first_name field' do
      Directory.search('Mo').should eq id1
    end

    it 'should search case-independently' do
      Directory.search('WhItEhOuSe').should eq id1
    end
  end

  describe 'search_ldap' do
    # TODO: for now, no tests for search_database; it talks to LDAP
    # directly
  end

  describe 'ldap_entries_not_in_database' do
    it 'should work' do
    end
  end

  describe 'create_identities' do
  end
end

