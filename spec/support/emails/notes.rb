module EmailHelpers

  def does_not_have_a_reminder_note(mail_response)
    expect(mail_response).not_to have_xpath "//p[text()='*Note(s) are included with this submission.']"
  end

  def does_have_a_reminder_note(mail_response)
    expect(mail_response).to have_xpath "//p[text()='*Note(s) are included with this submission.']"
  end

  def does_not_have_a_submission_reminder(mail_response)
    expect(mail_response).not_to have_xpath "//p[text()='*Note: upon submission, services selected to go to Epic will be sent daily at 4:30pm.']"
  end

  def does_have_a_submission_reminder(mail_response)
    expect(mail_response).to have_xpath "//p[text()='*Note: upon submission, services selected to go to Epic will be sent daily at 4:30pm.']"
  end

  def get_a_cost_estimate_does_not_have_notes(mail_response)
    does_not_have_a_reminder_note(mail_response)
    does_not_have_a_submission_reminder(mail_response)
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end