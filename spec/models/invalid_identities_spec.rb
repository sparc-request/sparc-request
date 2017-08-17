require 'rails_helper'

RSpec.describe InvalidIdentities, type: :model do
  describe '#remove_from_db' do
    it 'should delete identities if they meet requirements for deletion' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq []
    end

    it 'should delete identities if they meet requirements for deletion' do
      identity = create(
        :identity, :without_validations, email: nil, last_sign_in_at: nil
      )
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq []
    end

    it 'should keep if there is a sign in date' do
      identity = create(
        :identity, :without_validations, email: nil, last_sign_in_at: Time.now
      )
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end

    it 'should keep if identity has a project role' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      create(:project_role, :without_validations, identity: identity)
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end
    it 'should keep if identity is a catalog manager' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      create(:catalog_manager, identity: identity)
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end

    it 'should keep if identity is a clinical provider' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      create(:clinical_provider, identity: identity)
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end
    it 'should keep if identity is a service provider' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      create(:service_provider, identity: identity)
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end
    it 'should keep if identity is a super user' do
      identity = create(
        :identity, :without_validations, email: nil
      )
      create(:super_user, identity: identity)
      invalid_identities = InvalidIdentities.new([identity])

      invalid_identities.remove_from_db

      expect(Identity.all).to eq [identity]
    end
  end
end

