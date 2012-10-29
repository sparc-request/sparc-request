class Notifier < ActionMailer::Base
  def ask_a_question question
    @question = question
    mail(:to => @question.to, :from => @question.from, :subject => 'New Question from SPARC')
  end
end
