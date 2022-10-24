task update_study_question_16_text: :environment do
    @study_type_question_16 = StudyTypeQuestion.where(question: "4. Is it appropriate to display the pink \"Research: Active\" indicator in the Patient Header for all study participants?")
    @study_type_question_16.update(question: "Is it appropriate to display the yellow \"Research Participant\" advisory for all study participants?")
end
