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

RSpec.describe AdditionalDetails::PreviewsController do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#create' do
    before :each do
      @service = create( :service )
      @questionnaire = build( :questionnaire, service: @service, active: false )

      post :create, params: {
        name: 'Some Program',
        service_id: @service,
        questionnaire: @questionnaire.attributes
      }, format: :js
    end

    it 'should assign @questionnaire' do
      expect( assigns( :questionnaire ) ).to be_an_instance_of( Questionnaire )
    end

    it 'should assign @service' do
      expect( assigns( :service ) ).to be_an_instance_of( Service )
    end

    it 'should assign @submissions' do
      expect( assigns( :submission ) ).to be_an_instance_of( Submission )
    end

    it 'should build questionnaire responses for @submission' do
      expect( assigns( :submission ).questionnaire_responses ).to_not be_nil
    end

    it { is_expected.to render_template :create }

    it { is_expected.to respond_with :ok }
  end
end
