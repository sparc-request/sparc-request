require 'spec_helper'

describe "Ask a question", :js => true do
  before :each do
    visit root_path
    find('.ask-a-question-button').click()
  end

  describe 'clicking the button' do

    it 'should display the ask a question form' do
      find_by_id('ask-a-question-form').visible?.should eq(true)
    end
  end

  describe 'form validation' do

    it "should not show the error message if the email is correct" do
      find_by_id('quick_question_email').click()
      page.find('#quick_question_email').set 'juan@gmail.com'
      find('#submit_question').click()
      wait_for_javascript_to_finish
      find_by_id('ask-a-question-form').visible?.should eq(false)
    end

    it "should require an email" do
      find_by_id('quick_question_email').click()
      find('#submit_question').click()
      wait_for_javascript_to_finish
      find_by_id('ask-a-question-form').visible?.should eq(true)
      page.should have_content("Valid email address required.")
    end

    it "should display the error and not allow the form to submit if the email is not valid" do
      find_by_id('quick_question_email').click()
      page.find('#quick_question_email').set 'Pappy'
      find('#submit_question').click()
      wait_for_javascript_to_finish
      find_by_id('ask-a-question-form').visible?.should eq(true)
      page.should have_content("Valid email address required.")
    end
  end
end