# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe ServiceCalendarsController do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#view_full_calendar' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should assign @tab' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)

      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:tab)).to eq('calendar')
    end

    it 'should assign @review' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:review)).to eq(false)
    end

    it 'should assign @portal' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:portal)).to eq(true)
    end

    it 'should assign @merged' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)

      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:merged)).to eq(true)
    end

    it 'should assign @consolidated' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:consolidated)).to eq(true)
    end

    it 'should assign @service_request' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:service_request)).to eq(sr)
    end

    it 'should assign @statuses_hidden' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true',
        statuses_hidden: ['None for me, thank you']
      }, xhr: true

      expect(assigns(:statuses_hidden)).to eq(['None for me, thank you'])
    end

    it 'should assign and fill @pages' do
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol)
      arm1      = create(:arm, protocol: protocol, name: "Arm 1")
      arm2      = create(:arm, protocol: protocol, name: "Arm 2")

      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm1.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:pages).count).to eq(2)
      expect(assigns(:pages)[arm1.id]).to be
      expect(assigns(:pages)[arm2.id]).to be
    end

    it 'should assign @arm if params[:arm_id]' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm      = create(:arm, protocol: protocol, name: "Arm")

      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(assigns(:arm)).to eq(arm)
    end

    it 'should render template' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)

      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(controller).to render_template(:view_full_calendar)
    end

    it 'should respond ok' do
      protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm_without_validations, protocol: protocol)


      session[:identity_id] = logged_in_user.id

      get :view_full_calendar, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        arm_id: arm.id,
        portal: 'true'
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
