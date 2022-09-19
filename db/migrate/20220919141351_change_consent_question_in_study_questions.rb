class ChangeConsentQuestionInStudyQuestions < ActiveRecord::Migration[5.2]
  def change
    @stq = StudyTypeQuestion.find(13)
    @stq.update(question: "1. Does your Informed Consent contain IRB standard language describing the use of an <a href='https://research.musc.edu/resources/ori/irb/forms/consent-language/certificate-of-confidentiality/alias'>Alias Medical Record</a>? If Yes, The PI is responsible for consulting with the Epic Research Team to establish the process for creating alias identities (de-identification) for your study participants.")
  end
end
