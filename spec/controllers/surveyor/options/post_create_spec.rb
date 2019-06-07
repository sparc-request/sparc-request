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

RSpec.describe Surveyor::OptionsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity, ldap_uid: 'weh6@musc.edu') }
  stub_config("site_admins", ["weh6@musc.edu"])
  
  before :each do
    session[:identity_id] = logged_in_user.id
  end

  describe '#create' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_survey_builder_access' do
      expect(before_filters.include?(:authorize_survey_builder_access)).to eq(true)
    end

    it 'should assign @question to the question' do
      question = create(:question_without_validations)

      post :create, params: {
        question_id: question.id
      }, xhr: true

      expect(assigns(:question)).to eq(question)
    end

    it 'should assign @option to a new option' do
      question = create(:question_without_validations)

      expect{
        post :create, params: {
          question_id: question.id
        }, xhr: true
      }.to change{ Option.count }.by(1)
      expect(assigns(:option)).to be_an(Option)
    end

    it 'should render template' do
      question = create(:question_without_validations)

      post :create, params: {
        question_id: question.id
      }, xhr: true

      expect(controller).to render_template(:create)
    end

    it 'should respond ok' do
      question = create(:question_without_validations)

      post :create, params: {
        question_id: question.id
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
