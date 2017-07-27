# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe AdditionalDetails::UpdateQuestionnairesController do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#update' do
    before :each do
      @service        = create(:service)
      @questionnaire  = create(:questionnaire, :without_validations, service: @service, active: true)
    end

    it 'should assign @service' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(assigns(:service)).to eq(@service)
    end

    it 'should assign @questionnaires' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(assigns(:questionnaires)).to eq([@questionnaire])
    end

    it 'should assign @questionnaire' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(assigns(:questionnaire)).to eq(@questionnaire)
    end

    it 'should update status' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(@questionnaire.reload.active).to eq(false)

      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(@questionnaire.reload.active).to eq(true)
    end

    it 'should render template' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(controller).to render_template(:update)
    end

    it 'should respond ok' do
      patch :update, params: {
        service_id: @service.id,
        id: @questionnaire.id
      }, format: :js

      expect(controller).to respond_with(:ok)
    end
  end
end
