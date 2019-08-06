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

RSpec.describe Surveyor::ResponsesController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  before :each do
    @respondable = create(:sub_service_request_without_validations, organization: create(:organization))
  end

  describe '#new' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should assign @survey to the Survey' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(assigns(:survey)).to eq(survey)
    end

    it 'should assign @response as a new Response of Survey' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(assigns(:response)).to be_a_new(Response)
      expect(assigns(:response).survey).to eq(survey)
    end

    it 'should build question responses' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(assigns(:response).question_responses).to be
    end

    it 'should assign @respondable' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(assigns(:respondable)).to eq(@respondable)
    end

    context 'format.html (Taking Survey From Email Link)' do
      it 'should redirect if survey has already been taken by the user for the respondable' do
        survey = create(:form, active: true)
        existing_response = create(:response, survey: survey, identity: logged_in_user, respondable: @respondable)

        session[:identity_id] = logged_in_user
        
        get :new, params: {
          survey_id: survey.id,
          respondable_id: @respondable.id,
          respondable_type: 'SubServiceRequest',
          type: 'Survey',
          format: :html
        }, xhr: true

        expect(controller).to redirect_to(surveyor_response_complete_path(existing_response))
      end
    end

    it 'should respond :ok' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end

    it 'should render template' do
      survey = create(:form, active: true)

      get :new, params: {
        survey_id: survey.id,
        respondable_id: @respondable.id,
        respondable_type: 'SubServiceRequest',
        type: 'Survey'
      }, xhr: true

      expect(controller).to render_template(:new)
    end
  end
end
