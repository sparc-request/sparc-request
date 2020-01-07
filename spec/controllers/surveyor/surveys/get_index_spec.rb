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

RSpec.describe Surveyor::SurveysController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity, ldap_uid: 'weh6@musc.edu') }
  stub_config("site_admins", ["weh6@musc.edu"])
  
  before :each do
    session[:identity_id] = logged_in_user.id
  end

  describe '#index' do
    context 'format html' do
      it 'should render template' do
        get :index, params: {
          format: :html
        }, xhr: true

        expect(controller).to render_template(:index)
      end

      it 'should respond ok' do
        get :index, params: {
          format: :html
        }, xhr: true

        expect(controller).to respond_with(:ok)
      end
    end

    context 'format json' do
      context "params[:type] == 'SystemSurvey'" do
        it 'should assign @surveys to all SystemSurveys' do
          create(:system_survey_without_validations)

          get :index, params: {
            format: :json,
            type: 'SystemSurvey'
          }, xhr: true

          expect(assigns(:surveys)).to eq(SystemSurvey.all)
        end
      end

      context "params[:type] == 'Form'" do
        it 'should assign @surveys to all Forms for the user' do
          org = create(:organization)
                create(:super_user, identity: logged_in_user, organization: org)
                create(:form, surveyable: org)

          get :index, params: {
            format: :json,
            type: 'Form'
          }, xhr: true

          expect(assigns(:surveys)).to eq(Form.for(logged_in_user))
        end
      end

      it 'should render template' do
        get :index, params: {
          format: :json
        }, xhr: true

        expect(controller).to render_template(:index)
      end

      it 'should respond ok' do
        get :index, params: {
          format: :json
        }, xhr: true

        expect(controller).to respond_with(:ok)
      end
    end
  end
end
