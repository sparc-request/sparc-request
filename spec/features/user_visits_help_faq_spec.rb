require 'rails_helper'

RSpec.feature "User visits Help/FAQs", js: true do

	scenario 'and should see Questions' do
		given_i_am_viewing_help_faq
		i_should_see_frequently_asked_questions_in_the_dialog_box
	end

	scenario 'and should see the Answers to the Questions' do
		given_i_am_viewing_help_faq
		when_i_visit_the_answer_to_a_question
		then_i_should_see_the_answer
	end

	scenario 'and should not see the Answers to the Questions' do
		given_i_am_viewing_help_faq
		when_i_visit_the_answer_to_a_question
		and_then_visit_only_the_question
		then_i_should_only_see_the_question
	end

	def given_i_am_viewing_help_faq
		visit root_path
    find('.faq-button').click()
	end

	def i_should_see_frequently_asked_questions_in_the_dialog_box
		expect(page).to have_css('.ui-dialog')
		expect(page).to have_css('.help_question')
		expect(page).to have_selector('.help_answer', visible: false)
	end

	def when_i_visit_the_answer_to_a_question
		first('.help_question').click
	end

	def then_i_should_see_the_answer
		expect(page).to have_selector('.help_answer', visible: true)
	end

	def and_then_visit_only_the_question
		first('.help_question').click
	end

	def then_i_should_only_see_the_question
		expect(page).to have_css('.ui-dialog')
		expect(page).to have_css('.help_question')
		expect(page).to have_selector('.help_answer', visible: false)
	end

end