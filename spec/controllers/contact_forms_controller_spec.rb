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

RSpec.describe ContactFormsController, type: :controller do
  let!(:contact_form) do
    FactoryGirl.create(:contact_form)
  end

  describe 'GET #new' do
    it 'returns http success' do
      xhr :get, :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new instance to correct model' do
      xhr :get, :new
      expect(assigns(:contact_form).class).to eq ContactForm
    end
  end

  describe 'GET #create' do
    it 'returns http success' do
      xhr :post, :create, :contact_form => {
        subject: 'subject',
        email: 'email@email.com',
        message: 'sample message'
      }
      expect(response).to have_http_status(:success)
    end

    it 'should send an email' do
      expect { xhr :post, :create, :contact_form => {
        subject: 'subject',
        email: 'email@email.com',
        message: 'sample message'
      }}.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
