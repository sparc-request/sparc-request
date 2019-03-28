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

  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity, ldap_uid: 'weh6@musc.edu') }
  stub_config("site_admins", ["weh6@musc.edu"])
  
  before :each do
    session[:identity_id] = logged_in_user.id

    @survey = create(:survey_without_validations)
    section = create(:section, survey: @survey)
              create(:question, section: section)

    get :update_dependents_list, params: {
      survey_id: @survey.id
    }, xhr: true
  end

  describe '#update_dependents_list' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_survey_builder_access' do
      expect(before_filters.include?(:authorize_survey_builder_access)).to eq(true)
    end

    it 'should assign @survey to the survey' do
      expect(assigns(:survey)).to eq(@survey)
    end

    it 'should assign @questions to the questions' do
      expect(assigns(:questions)).to eq(@survey.questions)
    end

    it { is_expected.to render_template(:update_dependents_list) }

    it { is_expected.to respond_with(:ok) }
  end
end
