# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

describe "Feedback", :js => true do
  before :each do
    visit root_path
    find('.feedback-button').click()
  end

  describe 'selecting feedback' do
    it 'should display the feedback form' do
      find_by_id('feedback-form').visible?.should eq(true)
    end

    describe 'submitting feedback' do
      it 'should require text in the message box' do
        find_by_id('submit_feedback').click()
        wait_for_javascript_to_finish
        find_by_id('error-text').text.should eq "Message can't be blank"
      end

      it 'should not require an email and remove the form' do
        within("#feedback-form") do
          find_by_id('feedback_message').click()
          fill_in 'feedback_message', :with => "Testing 123"
          wait_for_javascript_to_finish
        end
        find_by_id('submit_feedback').click()
        wait_for_javascript_to_finish
        find('#feedback-form', :visible => false).visible?.should eq(false)
      end
    end
  end
end