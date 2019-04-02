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

RSpec.describe Funding::ServicesController, type: :controller do
  stub_controller
    let!(:before_filters) { find_before_filters }
    let!(:logged_in_user) { create(:identity, ldap_uid: 'john.doe@test.edu') }
    stub_config("funding_admins", ["john.doe@test.edu"])

    let!(:funding_org) { create(:organization)}
    let!(:ids) { [funding_org.id] }

    before :each do
      session[:identity_id] = logged_in_user.id 
      @setting = Setting.find_by_key("funding_org_ids")
      @default_value = @setting.value
      @service = create(:service, :without_validations, organization: funding_org)
    end

  
    describe "#show" do
  
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_funding_admin' do
      expect(before_filters.include?(:authorize_funding_admin)).to eq(true)
    end

    it 'should call before_filter #find_funding_opp' do
      expect(before_filters.include?(:find_funding_opp)).to eq(true)
    end

    it 'should assign @service to the service' do
      @setting.update_attribute(:value, ids.to_s)
      get :show, params: {
        id: @service.id
      }, xhr: true

      expect(assigns(:service)).to eq(@service)
      @setting.update_attribute(:value, @default_value)
    end

    it 'should render template' do
      @setting.update_attribute(:value, ids.to_s)
      get :show, params: {
        id: @service.id
      }, xhr: true

      expect(response).to render_template :show
      @setting.update_attribute(:value, @default_value)
    end
  end
end