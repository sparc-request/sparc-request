# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe Surveyor::SurveyUpdaterController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity, ldap_uid: 'weh6@musc.edu') }

  before :each do
    stub_const('SITE_ADMINS', ['weh6@musc.edu'])
    session[:identity_id] = logged_in_user.id
  end

  describe '#update' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_site_admin' do
      expect(before_filters.include?(:authorize_site_admin)).to eq(true)
    end

    it 'should assign @klass to params[:klass]' do
      survey = create(:survey)
      klass = 'survey'

      xhr :put, :update, {
        id: survey.id,
        klass: klass,
        survey: {
          version: 1
        }
      }

      expect(assigns(:klass)).to eq(klass)
    end

    it 'should assign @object to the correct object passed' do
      survey = create(:survey)
      klass = 'survey'

      xhr :put, :update, {
        id: survey.id,
        klass: klass,
        survey: {
          version: 1
        }
      }

      expect(assigns(:object)).to eq(survey)
    end

    it 'should assign @field' do
      survey = create(:survey)
      klass = 'survey'

      xhr :put, :update, {
        id: survey.id,
        klass: klass,
        survey: {
          version: 1
        }
      }

      expect(assigns(:field)).to eq('version')
    end

    context 'object valid' do
      it 'should update object' do
        survey = create(:survey, version: 0)
        klass = 'survey'

        xhr :put, :update, {
          id: survey.id,
          klass: klass,
          survey: {
            version: 1
          }
        }

        expect(survey.reload.version).to eq(1)
      end
    end

    context 'object invalid' do
      it 'should not update object' do
        survey = create(:survey, active: false)
        klass = 'survey'

        xhr :put, :update, {
          id: survey.id,
          klass: klass,
          survey: {
            title: nil
          }
        }

        expect(survey.reload.active).to eq(false)
      end

      it 'should assign @errors' do
        survey = create(:survey, active: false)
        klass = 'survey'

        xhr :put, :update, {
          id: survey.id,
          klass: klass,
          survey: {
            title: nil
          }
        }

        expect(assigns(:errors)).to be
      end
    end


    it 'should render template' do
      survey = create(:survey)
      klass = 'survey'

      xhr :put, :update, {
        id: survey.id,
        klass: klass,
        survey: {
          version: 1
        }
      }

      expect(controller).to render_template(:update)
    end

    it 'should respond ok' do
      survey = create(:survey)
      klass = 'survey'

      xhr :put, :update, {
        id: survey.id,
        klass: klass,
        survey: {
          version: 1
        }
      }

      expect(controller).to respond_with(:ok)
    end
  end
end
