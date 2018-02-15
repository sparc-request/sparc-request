# Copyright © 2011-2017 MUSC Foundation for Research Development
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

RSpec.describe Form, type: :model do

  # let!(:current_user) { create(:identity) }
  let!(:organization1)  { create(:organization) }
  let!(:organization2)  { create(:organization) }
  let!(:service1)       { create(:service, organization: organization1) }
  let!(:service2)       { create(:service, organization: organization2) }
  let!(:org_form1)      { create(:form, surveyable: organization1) }
  let!(:org_form2)      { create(:form, surveyable: organization2) }
  let!(:service_form1)  { create(:form, surveyable: service1) }
  let!(:service_form2)  { create(:form, surveyable: service2) }
  # let!(:user_form)    { create(:form, surveyable: current_user) }
  # let!(:super_user)   { create(:super_user, identity: current_user, organization: organization) }

  describe 'Form#for' do
    context 'User is a catalog overlord' do
      it 'should return forms associated to the user and all orgs + services' do
        current_user = create(:identity, catalog_overlord: true)
        user_form    = create(:form, surveyable: current_user)

        expect(Form.for(current_user).to_a.sort{ |l, r| l.id <=> r.id }).to eq([org_form1, org_form2, service_form1, service_form2, user_form])
      end
    end

    context 'User is not a catalog overlord but is a super user' do
      it 'should return forms associated to the user and admin orgs + services' do
        current_user = create(:identity)
        super_user   = create(:super_user, organization: organization1, identity: current_user)
        user_form    = create(:form, surveyable: current_user)

        expect(Form.for(current_user).to_a.sort{ |l, r| l.id <=> r.id }).to eq([org_form1, service_form1, user_form])
      end
    end

    context 'User is not a catalog overlord but is a service provider' do
      it 'should return forms associated to the user and admin orgs + services' do
        current_user      = create(:identity)
        service_provider  = create(:service_provider, organization: organization1, identity: current_user)
        user_form         = create(:form, surveyable: current_user)

        expect(Form.for(current_user).to_a.sort{ |l, r| l.id <=> r.id }).to eq([org_form1, service_form1, user_form])
      end
    end
  end
end
