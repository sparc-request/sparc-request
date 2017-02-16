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

RSpec.describe 'additional_details/submissions/_form', type: :view do


  let!(:logged_in_user) {create(:identity)}

  describe 'a new submission' do

    before(:each) do

      allow(controller).to receive(:current_identity).and_return(logged_in_user)

      @service = create(:service)
      @questionnaire =  create( :questionnaire, :without_validations, :with_all_question_types, service: @service)
      @submission = create( :submission_with_responses, questionnaire_id: @questionnaire.id )

      render '/additional_details/submissions/form'
    end

    it "uses the correct partials for a new form" do

      expect(response).to render_template(partial: "additional_details/submissions/_new_form")
      ADDITIONAL_DETAIL_QUESTION_TYPES.values.each do |qt|
        expect(response).to render_template(partial: "additional_details/submissions/form_partials/_#{qt}_form_partial")
      end
    end

    it "has the correct labels" do

      expect(response).to have_content('Questionnaire Submission')
      @questionnaire.items.each do |item|
        expect(response).to have_css('label', text: item.content)
      end
    end
  end

  describe 'an edited submission' do

    before(:each) do

      allow(controller).to receive(:current_identity).and_return(logged_in_user)

      @service = create(:service)
      @questionnaire =  create( :questionnaire, :with_all_question_types, :without_validations, service: @service)
      @submission = create( :submission_with_responses, questionnaire_id: @questionnaire.id)

      render '/additional_details/submissions/form', action_name: 'edit'
    end

    it "uses the correct partials for an edit form" do

      expect(response).to render_template(partial: "additional_details/submissions/_edit_form")
      ADDITIONAL_DETAIL_QUESTION_TYPES.values.each do |qt|
        expect(response).to render_template(partial: "additional_details/submissions/form_partials/_#{qt}_form_partial")
      end
    end

    it "has the correct labels" do

      expect(response).to have_content('Questionnaire Submission')
      @questionnaire.items.each do |item|
        expect(response).to have_css('label', text: item.content)
      end
    end
  end
end
