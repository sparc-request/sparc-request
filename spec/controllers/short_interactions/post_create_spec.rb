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

RSpec.describe ShortInteractionsController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#create' do
    it 'should assign @short_interaction' do 
      post :create, params: {
        short_interaction: {
          identity_id: logged_in_user.id,
          subject: 'general_question',
          interaction_type: 'email',
          duration_in_minutes: '10',
          name: 'tester', 
          email: 'test@test.com',
          institution: 'other', 
          note: 'interaction notes'
        }
      }, xhr: true

      expect(assigns(:short_interaction).class).to eq(ShortInteraction)
    end

    context 'short interaction valid' do
      it 'should create short_interaction' do
        post :create, params: {
          short_interaction: {
            identity_id: logged_in_user.id,
            subject: 'general_question',
            interaction_type: 'email',
            duration_in_minutes: '10',
            name: 'tester', 
            email: 'test@test.com',
            institution: 'other', 
            note: 'interaction notes'
          }
        }, xhr: true
        
        expect(ShortInteraction.count).to eq(1)
      end
    end

    context 'short_interaction invalid' do
      before :each do
        post :create, params:  {
          short_interaction: {
            identity_id: logged_in_user.id,
            subject: '',
            interaction_type: '',
            duration_in_minutes: '',
            name: '', 
            email: '',
            institution: '', 
            note: ''
          }
        }, xhr: true

      end

      it 'should assign @errors' do  
        expect(assigns(:errors)).to be
      end

      it 'should not create short_interaction ' do
        expect(ShortInteraction.count).to eq(0)
      end
    end

    it 'should render template' do
      post :create, params: {
        short_interaction: {
          identity_id: logged_in_user.id,
          subject: 'general_question',
          interaction_type: 'email',
          duration_in_minutes: '10',
          name: 'tester', 
          email: 'test@test.com',
          institution: 'other', 
          note: 'interaction notes'
        }
      }, xhr: true

      expect(controller).to render_template(:create)
    end

    it 'returns http success' do
      post :create, params: {
        short_interaction: {
          identity_id: logged_in_user.id,
          subject: 'general_question',
          interaction_type: 'email',
          duration_in_minutes: '10',
          name: 'tester', 
          email: 'test@test.com',
          institution: 'other', 
          note: 'interaction notes'
        }
      }, xhr: true
      expect(controller).to respond_with(:ok)
    end
  end
end
