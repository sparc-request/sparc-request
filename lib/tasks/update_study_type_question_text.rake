namespace :update_study_type_question_text do
  desc "TODO"
  task change_question_task: :environment do
    @stq = StudyTypeQuestion.where(friendly_id: "certificate_of_conf").second
    @stq.update(question: "1. Does your Informed Consent contain IRB standard language describing the use of an <a target='_blank' href='https://research.musc.edu/resources/ori/irb/forms/consent-language/certificate-of-confidentiality/alias'>Alias Medical Record</a>? If Yes, the PI is responsible for consulting with the Epic Research Team to establish the process for creating alias identities (de-identification) for your study participants.")

    @stq2 = StudyTypeQuestion.where(friendly_id: "higher_level_of_privacy").third
    @stq2.update(question: "2. Does your study require a higher level of privacy protection for the participants? <br> (Your study needs \"break the glass\" functionality in Epic because it is collecting sensitive data, such as HIV/sexually transmitted disease, sexual practice/attitudes, illegal substance, etc., which needs higher privacy protection, yet not complete de-identification of the study participant.)")
  end

end
