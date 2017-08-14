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

RSpec.describe Surveyor::ResponsesController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#create' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should assign @review' do
      survey = create(:survey)

      post :create, params: {
        review: 'true',
        response: {
          identity_id: logged_in_user.id,
          survey_id: survey.id
        }
      }, xhr: true

      expect(assigns(:review)).to eq(true)
    end

    context 'response is valid' do
      it 'should save @response' do
        survey = create(:survey)
        section = create(:section, survey: survey)
        question = create(:question, section: section, required: true)

        expect{
          post :create, params: {
            response: {
              identity_id: logged_in_user.id,
              survey_id: survey.id,
              question_responses_attributes: {
                '0' => {
                  required: 'true',
                  question_id: question.id,
                  content: 'response'
                }
              }
            }
          }, xhr: true
        }.to change{ Response.count }.by(1)
      end
    end

    context 'response is invalid' do
      it 'should not save @response' do
        survey = create(:survey)
        section = create(:section, survey: survey)
        question = create(:question, section: section, required: true)

        expect{
          post :create, params: {
            response: {
              identity_id: logged_in_user.id,
              survey_id: survey.id,
              question_responses_attributes: {
                '0' => {
                  required: 'true',
                  question_id: question.id
                }
              }
            }
          }, xhr: true
        }.to_not change{ Response.count }
      end

      it 'should assign @errors' do
        survey = create(:survey)
        section = create(:section, survey: survey)
        question = create(:question, section: section, required: true)
        
        post :create, params: {
          response: {
            identity_id: logged_in_user.id,
            survey_id: survey.id,
            question_responses_attributes: {
              '0' => {
                required: 'true',
                question_id: question.id
              }
            }
          }
        }, xhr: true

        expect(assigns(:errors)).to eq(true)
      end
    end

    it 'should render template' do
      survey = create(:survey)

      post :create, params: {
        response: {
          identity_id: logged_in_user.id,
          survey_id: survey.id
        }
      }, xhr: true

      expect(controller).to render_template(:create)
    end

    it 'should respond ok' do
      survey = create(:survey)

      post :create, params: {
        response: {
          identity_id: logged_in_user.id,
          survey_id: survey.id
        }
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
