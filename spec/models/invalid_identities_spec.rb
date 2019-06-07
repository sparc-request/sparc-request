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

