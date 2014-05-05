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

      # TODO: Can't get capybara to actually fill this in. Will come back to it after entire test suite is updated

      # it 'should not require an email and remove the form' do
      #   within("#feedback-form") do
      #     fill_in 'feedback_message', :with => "Testing 123"
      #     wait_for_javascript_to_finish
      #   end
      #   find_by_id('submit_feedback').click()
      #   wait_for_javascript_to_finish
      #   find_by_id('feedback-form').visible?.should eq(false)
      # end
    end
  end
end