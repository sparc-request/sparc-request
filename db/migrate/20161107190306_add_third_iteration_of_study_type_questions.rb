class AddThirdIterationOfStudyTypeQuestions < ActiveRecord::Migration
  def change
    change_column :study_type_questions, :question, :text
    
    friendly_ids = ['certificate_of_conf', 'higher_level_of_privacy', 'epic_inbasket', 'research_active', 'restrict_sending']

    study_type_questions_version_3 = ["1. Does your Informed Consent provide information to the participant specifically stating their study participation be kept private from anyone outside the research team? (i.e. your study has a Certificate of Confidentiality or involves sensitive data collection which requires de-identification of the research participant in Epic.)",
                                 "2. Does your study require a higher level of privacy protection for the participants? (Your study needs 'break the glass' functionality in Epic because it is collection sensitive data, such as HIV/sexually transmitted disease, sexual practice/attitudes, illegal substance, etc., which needs higher privacy protection, yet not complete de-identification of the study participant.)",
                                 "3. Is it appropriate for study team members to receive Epic InBasket notifications if research participants in this study are hospitalized or admitted to the Emergency Department?",
                                 "4. Is it appropriate to display the pink 'Research:Active indicator in the Patient Header for all study participants?'",
                                 "5. Is it appropriate for all study participants to receive associated test results, such as labs and/or imaging findings, via MyChart?"]
    study_type_questions_version_3.each_with_index do |stq, index|
      StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index], study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
    end
  end
end
