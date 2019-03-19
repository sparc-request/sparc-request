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

  let!(:survey)   { create(:survey) }
  let!(:resp)     { create(:response, survey: survey ) }
  let!(:section)  { create(:section, survey: survey) }
  let!(:question) { create(:question, section: section) }
  let!(:qr)       { create(:question_response, question: question, response: resp, content: 'not responding') }

  describe '#update' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should assign @response' do
      put :update, params: {
        id: resp.id,
        response: {
          question_responses_attributes: {
            '0' => {
              id: qr.id,
              question_id: question.id,
              required: 'true',
              content: 'responsibility'
            }
          }
        }
      }, xhr: true
      expect(assigns(:response)).to eq(resp)
    end

    context '@response is valid' do
      it 'should update @response' do
        put :update, params: {
          id: resp.id,
          response: {
            question_responses_attributes: {
              '0' => {
                id: qr.id,
                question_id: question.id,
                required: 'true',
                content: 'responsibility'
              }
            }
          }
        }, xhr: true
        expect(qr.reload.content).to eq('responsibility')
      end
    end

    context '@response is not valid' do
      it 'should not update @response' do
        put :update, params: {
        id: resp.id,
          response: {
            question_responses_attributes: {
              '0' => {
                id: qr.id,
                question_id: question.id,
                required: 'true',
                content: ''
              }
            }
          }
        }, xhr: true
        expect(qr.reload.content).to eq('not responding')
      end
    end

    it 'should respond :ok' do
      put :update, params: {
        id: resp.id,
        response: {
          question_responses_attributes: {
            '0' => {
              id: qr.id,
              question_id: question.id,
              required: 'true',
              content: 'responsibility'
            }
          }
        }
      }, xhr: true
      expect(controller).to respond_with(:ok)
    end

    it 'should render template' do
      put :update, params: {
        id: resp.id,
        response: {
          question_responses_attributes: {
            '0' => {
              id: qr.id,
              question_id: question.id,
              required: 'true',
              content: 'responsibility'
            }
          }
        }
      }, xhr: true
      expect(controller).to render_template(:update)
    end
  end
end
