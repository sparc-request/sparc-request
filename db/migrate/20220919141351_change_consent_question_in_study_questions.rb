class ChangeConsentQuestionInStudyQuestions < ActiveRecord::Migration[5.2]
  def change
    @stq = StudyTypeQuestion.where(question: "1. Does your Informed Consent provide information to the participant specifically stating their study participation will be kept private from anyone outside the research team? (i.e. your study has a Certificate of Confidentiality or involves sensitive data collection which requires de-identification of the research participant in Epic.)")
    @stq.update(question: "1. Does your Informed Consent contain IRB standard language describing the use of an <a href='https://research.musc.edu/resources/ori/irb/forms/consent-language/certificate-of-confidentiality/alias'>Alias Medical Record</a>? If Yes, The PI is responsible for consulting with the Epic Research Team to establish the process for creating alias identities (de-identification) for your study participants.")
  end
end
